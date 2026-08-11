/* ==========================================================================
   G-TEC eLessons — course detail page logic

   LOAD ORDER MATTERS: course-data.js -> detail.js -> gtec-ui.js
   This file renders synchronously so that by the time gtec-ui.js runs, every
   tab, price and disclosure it needs to bind already exists in the DOM.

   Prices are never converted here. Each .price element carries authored
   figures as data-inr / data-aed / data-usd, and the shared location-based
   switcher (geo-pricing.js) decides which one is shown.
   ========================================================================== */
(function () {
  'use strict';

  /* ---------- tiny helpers ---------- */
  function $(id) { return document.getElementById(id); }
  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function cur() { return document.documentElement.getAttribute('data-currency') || 'inr'; }

  /* Fuzzy search: substring first, then tolerant token / typo matching so
     "phsyics", "ex 1.1", or spaced OCR titles still hit the right lessons. */
  function normalizeSearch(s) {
    return String(s || '')
      .toLowerCase()
      .replace(/[^a-z0-9.\s]+/g, ' ')
      .replace(/\bex(?:ercises?)?\.?\b/g, 'exercise')
      .replace(/\s+/g, ' ')
      .trim();
  }
  function editDistance(a, b) {
    if (a === b) return 0;
    var al = a.length, bl = b.length;
    if (!al) return bl;
    if (!bl) return al;
    if (Math.abs(al - bl) > 4) return 99;
    var prev = new Array(bl + 1);
    var curRow = new Array(bl + 1);
    var i, j, tmp;
    for (j = 0; j <= bl; j++) prev[j] = j;
    for (i = 1; i <= al; i++) {
      curRow[0] = i;
      for (j = 1; j <= bl; j++) {
        curRow[j] = a.charAt(i - 1) === b.charAt(j - 1)
          ? prev[j - 1]
          : 1 + Math.min(prev[j - 1], prev[j], curRow[j - 1]);
      }
      tmp = prev; prev = curRow; curRow = tmp;
    }
    return prev[bl];
  }
  function fuzzyAllowance(len) {
    if (len <= 2) return 0;
    if (len <= 4) return 1;
    if (len <= 7) return 2;
    return Math.min(3, Math.floor(len * 0.3));
  }
  function fuzzyTokenMatch(hay, needle) {
    if (!needle) return true;
    if (hay.indexOf(needle) !== -1) return true;
    var max = fuzzyAllowance(needle.length);
    if (Math.abs(hay.length - needle.length) <= max && editDistance(hay, needle) <= max) {
      return true;
    }
    /* Sliding window: allow typos inside a longer title ("rational numbrs"). */
    if (hay.length > needle.length && needle.length >= 3) {
      var win = needle.length;
      var i, slice, dist;
      for (i = 0; i <= hay.length - win; i++) {
        slice = hay.slice(i, i + win);
        dist = editDistance(slice, needle);
        if (dist <= max) return true;
        if (i + win + 1 <= hay.length) {
          dist = editDistance(hay.slice(i, i + win + 1), needle);
          if (dist <= max) return true;
        }
      }
    }
    return false;
  }
  function fuzzyMatch(haystack, needle) {
    var h = normalizeSearch(haystack);
    var n = normalizeSearch(needle);
    if (!n) return true;
    if (h.indexOf(n) !== -1) return true;
    var nTokens = n.split(' ').filter(Boolean);
    var hTokens = h.split(' ').filter(Boolean);
    if (!nTokens.length) return true;
    return nTokens.every(function (nt) {
      if (h.indexOf(nt) !== -1) return true;
      return hTokens.some(function (ht) { return fuzzyTokenMatch(ht, nt); }) ||
        fuzzyTokenMatch(h.replace(/\s+/g, ''), nt.replace(/\s+/g, ''));
    });
  }

  /* Single analytics choke point — wire GTM once, don't scatter tags. */
  function track(event, params) {
    var p = params || {};
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push(Object.assign({ event: event }, p));
    if (typeof window.gtag === 'function') window.gtag('event', event, p);
  }
  window.elTrack = track;


  /* ══════════════ CART (localStorage) ══════════════
     Brochure → store: parents can bundle packages and subjects
     without losing context. Checkout opens checkout.html (WhatsApp handoff until
     card payment is wired) — the cart itself is real and survives reloads. */
  var CART_KEY = 'elessons_cart_v1';
  var GRADE_TINT = { 8: '#0D7377', 9: '#073790', 10: '#5B3E96', 11: '#9A3412', 12: '#1B6A47' };

  function loadCart() {
    try { return JSON.parse(localStorage.getItem(CART_KEY) || '{"items":[]}'); }
    catch (e) { return { items: [] }; }
  }
  function saveCart(cart) {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
  }
  function cartCount(cart) { return (cart || loadCart()).items.length; }
  function cartTotal(cart) {
    return (cart || loadCart()).items.reduce(function (t, it) {
      return addMoney(t, it.price || { inr: 0, aed: 0 });
    }, { inr: 0, aed: 0 });
  }
  function cartHas(id) {
    return loadCart().items.some(function (it) { return it.id === id; });
  }
  function makeCartItem(partial) {
    return {
      id: partial.id,
      type: partial.type,
      grade: partial.grade,
      subject: partial.subject || null,
      mode: partial.mode,
      title: partial.title,
      subtitle: partial.subtitle || '',
      price: { inr: partial.price.inr, aed: partial.price.aed, usd: partial.price.usd || 0 }
    };
  }
  function addCartItem(item, opts) {
    var cart = loadCart();
    if (cart.items.some(function (it) { return it.id === item.id; })) {
      toast('Already in your cart');
      openCart();
      return false;
    }
    cart.items.push(item);
    try { saveCart(cart); } catch (err) { /* private mode / blocked storage */ }
    track('add_to_cart', {
      item_id: item.id, item_name: item.title,
      value: item.price[cur()], currency: cur().toUpperCase()
    });
    paintCart();
    if (!opts || opts.open !== false) openCart();
    toast('Added to cart');
    return true;
  }
  function removeCartItem(id) {
    var cart = loadCart();
    cart.items = cart.items.filter(function (it) { return it.id !== id; });
    saveCart(cart);
    track('remove_from_cart', { item_id: id });
    paintCart();
    paintTiers();
  }
  function clearCart() {
    saveCart({ items: [] });
    paintCart();
    paintTiers();
  }

  function openCart() {
    var d = $('cart-drawer'), s = $('cart-scrim');
    if (!d) return;
    d.hidden = false; s.hidden = false;
    document.body.classList.add('cart-open');
    var close = $('cart-close');
    if (close) close.focus();
  }
  function closeCart() {
    var d = $('cart-drawer'), s = $('cart-scrim');
    if (!d) return;
    d.hidden = true; s.hidden = true;
    document.body.classList.remove('cart-open');
  }

  function paintCart() {
    var cart = loadCart();
    var n = cartCount(cart);
    var badge = $('cart-badge');
    if (badge) {
      badge.hidden = n === 0;
      badge.textContent = String(n);
    }
    document.body.classList.toggle('cart-has-items', n > 0);

    var empty = $('cart-empty');
    var foot = $('cart-foot');
    var box = $('cart-items');
    if (!box) return;

    /* Keep the empty-state node; rebuild lines after it. */
    Array.prototype.slice.call(box.querySelectorAll('.cart-line')).forEach(function (el) { el.remove(); });

    if (n === 0) {
      if (empty) empty.hidden = false;
      if (foot) foot.hidden = true;
    } else {
      if (empty) empty.hidden = true;
      if (foot) foot.hidden = false;
      cart.items.forEach(function (it) {
        var a = priceAttrs(it.price);
        var row = document.createElement('div');
        row.className = 'cart-line';
        row.innerHTML =
          '<div><p class="cart-line__title">' + esc(it.title) + '</p>' +
          '<p class="cart-line__meta">' + esc(it.subtitle || ((it.mode === 'live' ? 'Recorded + Mentorship support' : 'Recorded') + ' · Grade ' + it.grade)) + '</p></div>' +
          '<p class="cart-line__price price" data-inr="' + a.inr + '" data-aed="' + a.aed + '" data-usd="' + a.usd + '">' + a[cur()] + '</p>' +
          '<button type="button" class="cart-line__remove" data-cart-remove="' + esc(it.id) + '">Remove</button>';
        box.appendChild(row);
      });
      box.querySelectorAll('[data-cart-remove]').forEach(function (b) {
        b.addEventListener('click', function () { removeCartItem(b.dataset.cartRemove); });
      });
      var tot = cartTotal(cart);
      var totEl = $('cart-total');
      if (totEl) setPrice(totEl, tot);
      var label = $('cart-count-label');
      if (label) label.textContent = n + ' item' + (n === 1 ? '' : 's');
    }

    /* Sticky bar flips to cart summary when the cart has items. */
    var bar = $('stickybar');
    if (bar && n > 0) {
      bar.dataset.mode = 'cart';
      setPrice($('bar-price'), cartTotal(cart));
      $('bar-meta').textContent = n + ' item' + (n === 1 ? '' : 's') + ' in cart';
      $('bar-buy').textContent = 'View cart';
      $('bar-buy').removeAttribute('aria-disabled');
      $('bar-buy').style.opacity = '';
      $('bar-buy').style.pointerEvents = '';
    } else if (bar) {
      bar.dataset.mode = 'product';
      setPrice($('bar-price'), currentPrice());
      $('bar-meta').textContent =
        (S.mode === 'live' ? 'Recorded + Mentorship support' : 'Recorded') + ' \u00b7 Grade ' + S.grade;
      $('bar-buy').textContent = 'Add to cart';
      $('bar-buy').removeAttribute('aria-disabled');
      $('bar-buy').style.opacity = '';
      $('bar-buy').style.pointerEvents = '';
    }

    repaint();
    scheduleWaFloat();
  }

  function currentCartId() {
    if (S.plan === 'full') {
      if (isStreamGrade(S.grade) && S.stream) return 'g' + S.grade + '-' + S.stream + '-' + S.mode;
      return 'g' + S.grade + '-full-' + S.mode;
    }
    return 'g' + S.grade + '-' + S.subject + '-' + S.mode;
  }

  function addCurrentPlanToCart() {
    var p = currentPrice();
    var id = currentCartId();
    addCartItem(makeCartItem({
      id: id, type: S.plan, grade: S.grade, subject: S.plan === 'subject' ? S.subject : null,
      mode: S.mode, title: currentTitle(),
      subtitle: (S.mode === 'live' ? 'Recorded + Mentorship support' : 'Recorded') + ' · Full academic year',
      price: p
    }));
  }

  function bindCartUi() {
    var openers = ['cart-open'];
    openers.forEach(function (id) {
      var el = $(id);
      if (el) el.addEventListener('click', function (e) { e.preventDefault(); openCart(); });
    });
    var closer = $('cart-close');
    if (closer) closer.addEventListener('click', closeCart);
    var scrim = $('cart-scrim');
    if (scrim) scrim.addEventListener('click', closeCart);
    var browse = $('cart-browse');
    if (browse) browse.addEventListener('click', function () { closeCart(); });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !$('cart-drawer').hidden) closeCart();
    });
    var checkout = $('cart-checkout');
    if (checkout) checkout.addEventListener('click', function () {
      var cart = loadCart();
      if (!cart.items.length) { toast('Your cart is empty'); return; }
      var tot = cartTotal(cart);
      var currency = cur();
      var symbol = currency === 'aed' ? 'AED ' : currency === 'usd' ? '$' : '\u20B9';
      var locale = currency === 'inr' ? 'en-IN' : 'en-US';
      var lines = cart.items.map(function (it) {
        var p = (it.price && it.price[currency] != null) ? it.price[currency] : 0;
        return '- ' + (it.title || it.id) + ' (' + symbol + Number(p).toLocaleString(locale) + ')';
      });
      var msg = 'Hi G-TEC eLessons, I would like to enrol.\n\n' +
        lines.join('\n') +
        '\n\nTotal: ' + symbol + Number(tot[currency] || 0).toLocaleString(locale) +
        '\nCurrency: ' + currency.toUpperCase() +
        '\n\nPlease share payment and LMS activation steps.';
      track('begin_checkout', {
        value: tot[currency], currency: currency.toUpperCase(),
        items: cart.items.map(function (it) { return it.id; })
      });
      /* Card checkout page is not live yet — hand off to WhatsApp with a clear cart summary. */
      var href = (typeof elWhatsAppHref === 'function')
        ? elWhatsAppHref(msg, currency)
        : ('https://wa.me/' + (ELESSONS.whatsappInr || ELESSONS.whatsapp || '919745553944') +
           '?text=' + encodeURIComponent(msg));
      window.open(href, '_blank', 'noopener');
    });
  }

  /* Writes all authored figures, then shows the active one. */
  function setPrice(el, money) {
    if (!el) return;
    var a = priceAttrs(money);
    el.dataset.inr = a.inr;
    el.dataset.aed = a.aed;
    el.dataset.usd = a.usd;
    el.textContent = a[cur()];
  }
  /* Re-paints after location-based currency detection (no manual switcher). */
  function repaint() {
    if (window.ELessonsGeoPricing && typeof window.ELessonsGeoPricing.render === 'function') {
      var cur = document.documentElement.getAttribute('data-currency') || 'inr';
      var cc = document.documentElement.getAttribute('data-geo-country') || '';
      window.ELessonsGeoPricing.render(cur, cc);
      return;
    }
    document.querySelectorAll('.price').forEach(function (el) {
      var v = el.dataset[cur()];
      if (v) el.textContent = v;
    });
  }

  var ICON_TICK = '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>';

  /* ---------- state from the URL ---------- */
  var qp = new URLSearchParams(location.search);
  var S = {
    grade:   PRICING[qp.get('grade')] ? Number(qp.get('grade')) : 9,
    plan:    ['full', 'subject'].indexOf(qp.get('plan')) > -1 ? qp.get('plan') : 'full',
    subject: null,
    stream:  null,
    mode:    'live' /* Live + Recorded only — no recorded-only SKU */
  };
  /* Grades 11–12: stream packages. Legacy ?subject= links map to a sensible stream. */
  if (isStreamGrade(S.grade)) {
    var reqStream = (qp.get('stream') || '').toLowerCase();
    if (packagesForGrade(S.grade).indexOf(reqStream) > -1) {
      S.stream = reqStream;
    } else {
      var legacySub = (qp.get('subject') || '').toLowerCase();
      if (legacySub === 'english' || legacySub === 'maths') S.stream = 'pcmb';
      else if (legacySub === 'science') S.stream = 'pcmb';
      else if (legacySub === 'accountancy') S.stream = 'commerce';
      else if (['physics', 'chemistry', 'biology', 'computer'].indexOf(legacySub) > -1) S.stream = 'pcmb';
      else {
        var pkgs = packagesForGrade(S.grade);
        /* Grade 11 has no dedicated PCMB syllabus PDF yet — prefer PCMC when present. */
        if (S.grade === 11 && pkgs.indexOf('pcmc') > -1) S.stream = 'pcmc';
        else S.stream = pkgs[0] || 'pcmb';
      }
    }
    var streamSubs = subjectsForGrade(S.grade, S.stream);
    var reqPlan = qp.get('plan');
    var reqSub = (qp.get('subject') || '').toLowerCase();
    if (reqPlan === 'subject' && streamSubs.indexOf(reqSub) > -1) {
      S.plan = 'subject';
      S.subject = reqSub;
    } else {
      S.plan = 'full';
      S.subject = null;
    }
  } else {
    var subs = subjectsForGrade(S.grade);
    S.subject = subs.indexOf(qp.get('subject')) > -1 ? qp.get('subject') : subs[0];
  }

  /* ---------- current price ---------- */
  function currentPrice() {
    return planPrice(S.grade, S.plan, S.mode, S.subject, S.stream);
  }
  function currentTitle() {
    if (S.plan === 'subject' && S.subject && SUBJECT_META[S.subject]) {
      return 'Grade ' + S.grade + ' \u2014 ' + SUBJECT_META[S.subject].name;
    }
    if (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream]) {
      return 'Grade ' + S.grade + ' \u2014 ' + PACKAGE_META[S.stream].name;
    }
    return 'Grade ' + S.grade + ' \u2014 Annual Package';
  }
  function waContext() { return currentTitle().replace(/\u2014/g, '-'); }

  /* ══════════════ HERO ══════════════ */
  function paintHero() {
    var t = currentTitle();
    $('course-title').textContent = t;
    $('crumb-current').textContent = t;
    document.title = t + ' | G-TEC eLessons.net';

    var pv = previewFor(S.grade, S.plan, S.subject);
    var stage = document.getElementById('lesson-player');
    if (stage) {
      var cover = stage.querySelector('.player-cover');
      var banner = S.plan === 'subject' && SUBJECT_META[S.subject]
        ? SUBJECT_META[S.subject].banner
        : (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream]
            ? PACKAGE_META[S.stream].banner
            : 'sb-bundle');
      // poster = the same artwork the card uses, pulled from gtec.css
      if (cover) cover.className = 'player-cover sub-banner ' + banner;
      var pt = stage.querySelector('.player-title');
      if (pt) pt.textContent = pv.title;
      window.__elPreviewCtx = { grade: S.grade, plan: S.plan, subject: S.subject };
      var mediaId = pv.driveId || pv.vid || '';
      var prevId = stage.dataset.drive || stage.dataset.vid || '';
      stage.dataset.drive = pv.driveId || '';
      stage.dataset.vid = pv.driveId ? '' : (pv.vid || '');
      stage.dataset.cap = String(pv.cap);
      if (prevId !== mediaId && typeof window.gtecPlayerReset === 'function') {
        window.gtecPlayerReset(mediaId, pv.cap, pv.title);
      }
    }

    $('course-lede').textContent = S.plan === 'subject' && SUBJECT_META[S.subject]
      ? SUBJECT_META[S.subject].blurb
      : (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream])
        ? PACKAGE_META[S.stream].blurb
        : 'Maths, Science and English together for grade ' + S.grade +
          ' \u2014 every lesson and notes file, with English Grammar included free.';

    /* Counts must describe THIS purchase, not the whole catalog, and must not
       borrow another grade's syllabus. */
    var lc = $('fact-lessons'), cc = $('fact-chapters');
    if (hasRegister(S.grade, S.stream)) {
      var n = planLessonCount(S.grade, S.plan, S.subject, S.stream);
      var c = planChapterCount(S.grade, S.plan, S.subject, S.stream);
      lc.hidden = cc.hidden = false;
      lc.innerHTML = '<strong>' + n + '</strong> video lesson' + (n === 1 ? '' : 's');
      cc.innerHTML = '<strong>' + c + '</strong> chapter' + (c === 1 ? '' : 's');
    } else {
      lc.hidden = cc.hidden = true;
      lc.textContent = cc.textContent = '';
    }
  }

  /* ══════════════ PRICE / BUY PANEL ══════════════ */
  function paintPrice() {
    var p = currentPrice();
    setPrice($('buy-price'), p);
    setPrice($('bar-price'), p);

    var wasWrap = $('buy-was-wrap'), saveEl = $('buy-save');
    if (S.plan === 'full' && !isStreamGrade(S.grade)) {
      var mrp = fullMrp(S.grade, S.stream);
      var save = { inr: mrp.inr - p.inr, aed: mrp.aed - p.aed };
      wasWrap.hidden = false;
      setPrice($('buy-was'), mrp);
      if (save.inr > 0) {
        saveEl.hidden = false;
        saveEl.innerHTML = 'Save <span class="price"></span> against buying the three separately';
        setPrice(saveEl.querySelector('.price'), save);
      } else { saveEl.hidden = true; }
    } else {
      wasWrap.hidden = true;
      saveEl.hidden = true;
    }

    $('buy-unit').textContent =
      S.plan === 'subject' ? 'This subject \u00b7 full academic year'
                           : (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream]
                              ? (PACKAGE_META[S.stream].name + ' stream \u00b7 English Grammar free')
                              : 'All subjects \u00b7 English Grammar free');

    var up = upgradeOffer(S.grade, S.plan, S.mode, S.subject, S.stream);
    var upEl = $('buy-upgrade');
    if (upEl) {
      if (up) {
        upEl.hidden = false;
        setPrice($('upgrade-diff'), up.diff);
        var extra = $('upgrade-extra');
        if (extra) {
          extra.textContent = up.extraLessons != null
            ? '\u2014 ' + up.extraLessons + ' more lessons'
            : '';
        }
      } else {
        upEl.hidden = true;
      }
    }

    var bar = $('stickybar');
    if (!bar || bar.dataset.mode !== 'cart') {
      $('bar-meta').textContent =
        (S.mode === 'live' ? 'Recorded + Mentorship support' : 'Recorded') + ' \u00b7 Grade ' + S.grade;
      $('bar-buy').textContent = 'Add to cart';
      [$('buy-now'), $('bar-buy')].forEach(function (b) {
        if (!b) return;
        b.removeAttribute('aria-disabled');
        b.style.opacity = '';
        b.style.pointerEvents = '';
      });
    }

    document.querySelectorAll('[data-wa-course]').forEach(function (a) {
      a.dataset.wa = waContext();
    });
    bindWa();
    paintSchema(p);
    repaint();
  }

  function paintSchema(p) {
    var el = $('ld-course');
    if (!el) return;
    try {
      var j = JSON.parse(el.textContent);
      j.name = currentTitle();
      j.offers.price = String(p[cur()] || p.inr);
      j.offers.priceCurrency = cur() === 'aed' ? 'AED' : cur() === 'usd' ? 'USD' : 'INR';
      el.textContent = JSON.stringify(j, null, 1);
    } catch (e) { /* schema is decorative; never let it break the page */ }
  }

  /* ══════════════ MODE (fixed: Live + Recorded) ══════════════ */
  function bindMode() {
    /* No mode switcher — every purchase includes live classes and recordings. */
  }

  /* ══════════════ PURCHASE TIERS ══════════════ */
  function tierCard(opts) {
    var modeHtml = '<span class="mode mode-live"><span class="dot-live"></span>Recorded + Mentorship support</span>';
    return '<article class="tier' + (opts.on ? ' tier-on' : '') + '">' +
      '<p class="mono card-kicker" style="color:' + opts.colour + '">' + esc(opts.kicker) + '</p>' +
      '<h3 class="h3">' + esc(opts.title) + '</h3>' +
      '<div class="modes">' + modeHtml + '</div>' +
      '<p class="price tier-price" data-inr="' + opts.price.inr + '" data-aed="' + opts.price.aed + '" data-usd="' + opts.price.usd + '">' + opts.price.inr + '</p>' +
      '<p style="color:var(--slate-500);font-size:.75rem">' + esc(opts.note) + '</p>' +
      '<ul class="tier-inc">' + opts.inc.map(function (i) {
        return '<li>' + ICON_TICK + '<span>' + esc(i) + '</span></li>';
      }).join('') + '</ul>' +
      '<div class="tier-foot">' +
        '<button type="button" class="btn btn-red btn-sm btn-block" data-choose="' + opts.choose + '">' + esc(opts.cta) + '</button>' +
      '</div></article>';
  }

  function paintTiers() {
    var g = S.grade;
    var isLive = S.mode === 'live';

    /* Grades 11–12: show only the stream the parent opened (Commerce page
       must not list PCMB/PCMC here — those live under Related). */
    if (isStreamGrade(g)) {
      var pkgs = packagesForGrade(g).filter(function (pkg) {
        return !S.stream || pkg === S.stream;
      });
      if (!pkgs.length) pkgs = packagesForGrade(g);
      $('tier-full').innerHTML = pkgs.map(function (pkg) {
        var meta = PACKAGE_META[pkg];
        var fp = planPrice(g, 'full', S.mode, null, pkg);
        var nLessons = hasRegister(g, pkg) ? planLessonCount(g, 'full', null, pkg) : null;
        return tierCard({
          on: S.plan === 'full', colour: meta.colour, live: isLive,
          kicker: 'Grade ' + g + ' \u00b7 stream package',
          title: meta.name, price: priceAttrs(fp),
          note: 'English Grammar included free',
          inc: [meta.tag,
                nLessons != null ? nLessons + ' video lessons' : 'Every chapter of this stream',
                'Complimentary English Grammar',
                'Downloadable PDF notes', 'Full academic year of LMS access',
                isLive ? 'Weekly live sessions, each one recorded' : 'Watch at your own pace, unlimited replays'],
          cta: 'Add to cart', choose: 'stream:' + pkg
        });
      }).join('');
    } else {
      /* Full package */
      var fp = planPrice(g, 'full', S.mode), mrp = fullMrp(g);
      $('tier-full').innerHTML = tierCard({
        on: S.plan === 'full', colour: 'var(--navy-600)', kicker: 'Best value \u00b7 all subjects',
        title: 'Grade ' + g + ' Annual Package', price: priceAttrs(fp), live: isLive,
        note: 'Save ' + fmtMoney(mrp.inr - fp.inr, 'inr') + ' against buying separately \u00b7 English Grammar free',
        inc: ['Maths, Science and English in full',
              hasRegister(g, S.stream) ? registerTotal(g, null, S.stream) + ' video lessons across ' + chapterTotal(g, S.stream) + ' chapters'
                             : 'Every chapter of the CBSE / NCERT syllabus',
              'English Grammar complimentary with the annual package',
              'Downloadable PDF notes for every chapter', 'Full academic year of LMS access',
              isLive ? 'Weekly live sessions, each one recorded' : 'Watch at your own pace, unlimited replays'],
        cta: 'Add to cart', choose: 'full'
      });
    }

    document.querySelectorAll('[data-choose]').forEach(function (b) {
      b.addEventListener('click', function () {
        var v = b.dataset.choose.split(':');
        if (v[0] === 'stream') {
          S.plan = 'full';
          S.stream = v[1];
          S.subject = null;
          if (history && history.replaceState) {
            history.replaceState(null, '', 'course-detail.html?grade=' + S.grade +
              '&plan=full&stream=' + encodeURIComponent(S.stream) + '&mode=' + S.mode);
          }
        } else {
          S.plan = v[0];
          if (v[1]) S.subject = v[1];
          if (isStreamGrade(S.grade) && history && history.replaceState) {
            var q = 'course-detail.html?grade=' + S.grade + '&plan=' + encodeURIComponent(S.plan) +
              '&stream=' + encodeURIComponent(S.stream) + '&mode=' + S.mode;
            if (S.plan === 'subject' && S.subject) q += '&subject=' + encodeURIComponent(S.subject);
            history.replaceState(null, '', q);
          }
        }
        paintHero(); paintPrice(); paintTiers(); paintStreamTabs(); paintRegister(); paintRelated(); syncControls();
        track('plan_select', { plan: S.plan, subject: S.subject, stream: S.stream, mode: S.mode, grade: S.grade });
        addCurrentPlanToCart();
      });
    });

    repaint();
  }

  /* ══════════════ VIDEO REGISTER ══════════════ */
  var stream = null, query = '';

  function planStreams() { return streamsForPlan(S.grade, S.plan, S.subject, S.stream); }

  function paintStreamTabs() {
    var keys = planStreams();
    if (keys.indexOf(stream) === -1) stream = keys[0] || null;
    $('stream-tabs').hidden = keys.length < 2;
    $('stream-tabs').innerHTML = keys.map(function (k) {
      return '<button class="tab" role="tab" data-stream="' + k + '" aria-selected="' + (k === stream) + '">' +
        esc(STREAM_META[k].label) +
        (STREAM_META[k].complimentary ? ' <span class="mono" style="font-size:.58rem;color:var(--gold)">Free</span>' : '') +
        '<small>' + streamCount(S.grade, k, null, S.stream) + ' lessons</small></button>';
    }).join('');

    /* When only one subject is being bought, say what the full package adds
       rather than silently hiding the rest of the catalog. */
    var up = $('register-upsell');
    var hidden = registerStreams(S.grade, S.stream).filter(function (k) { return keys.indexOf(k) === -1; });
    if (S.plan === 'subject' && hidden.length && hasRegister(S.grade, S.stream)) {
      var extra = hidden.reduce(function (n, k) { return n + streamCount(S.grade, k, null, S.stream); }, 0);
      up.hidden = false;
      up.innerHTML = 'Showing the ' + esc(SUBJECT_META[S.subject].name) + ' syllabus only. ' +
        'The Grade ' + S.grade + ' Annual Package adds ' + extra + ' more lessons across ' +
        hidden.map(function (k) { return esc(STREAM_META[k].label); }).join(', ') +
        ' \u2014 <a href="#tiers" data-see-full>see the full package</a>.';
      up.querySelector('[data-see-full]').addEventListener('click', function () {
        track('upsell_click', { from: S.subject, grade: S.grade });
      });
    } else { up.hidden = true; }

    /* Re-rendering the buttons drops the handlers gtec-ui.js bound at load. */
    if (typeof window.gtecInitTablist === 'function') window.gtecInitTablist($('stream-tabs'));
  }

  function paintRegister() {
    var dl = $('download-pdf');
    if (dl && typeof classListPdfFor === 'function') {
      var href = classListPdfFor(S.grade, S.stream || 'pcmb');
      if (href) {
        dl.hidden = false;
        dl.href = href;
        if (/\.pdf($|\?)/i.test(href)) dl.setAttribute('download', '');
        else dl.removeAttribute('download');
      }
    }
    /* No published class list for this grade: say so plainly instead of
       showing another grade's chapters. */
    if (!hasRegister(S.grade, S.stream)) {
      $('register-body').innerHTML =
        '<div class="reg-empty"><p class="h3">The Grade ' + S.grade + ' class list is being published</p>' +
        '<p style="margin-top:.5rem;font-size:.9rem;max-width:52ch;margin-inline:auto">Lesson titles for this ' +
        'grade are not on the site yet. The syllabus follows the same CBSE / NCERT sequence \u2014 message us and ' +
        'we will send the chapter list for Grade ' + S.grade + '.</p>' +
        '<a class="btn btn-red btn-sm mt3" data-wa="Grade ' + S.grade + ' class list" href="#">Ask for the class list</a></div>';
      $('register-summary').textContent = 'Class list coming soon';
      var pt0 = $('register-plan-total');
      if (pt0) pt0.textContent = '';
      $('register-search').hidden = true;
      $('download-pdf').hidden = true;
      bindWa();
      return;
    }
    $('register-search').hidden = false;
    $('download-pdf').hidden = false;

    var chapters = stream ? streamChapters(S.grade, stream, S.stream) : [];
    var q = query.trim().toLowerCase();
    var running = 0, hits = 0, html = '';

    chapters.forEach(function (ch, ci) {
      if (isRegisterHeaderChapter(ch)) return;
      /* Bind the true running position BEFORE filtering: titles repeat inside a
         chapter ("Solved Problems" three times in Force and Laws of Motion), so
         an indexOf lookup would give two rows the same number. */
      var lessons = publishedLessons(ch).map(function (l, i) {
        return { item: l, n: running + i + 1, first: i === 0 };
      });
      running += lessons.length;

      var vis = q ? lessons.filter(function (e) {
        return fuzzyMatch(lessonTitle(e.item), q) || fuzzyMatch(ch.c, q);
      }) : lessons;
      if (!vis.length) return;
      hits += vis.length;

      var chapTitle = (typeof elHumanizeTitle === 'function') ? elHumanizeTitle(ch.c) : ch.c;
      html += '<details class="chap"' + (q || ci === 0 ? ' open' : '') + '>' +
        '<summary><span class="chap-n">' + String(ci + 1).padStart(2, '0') + '</span>' +
          '<span>' + esc(chapTitle) + '</span>' +
          '<span class="chap-count">' + vis.length + ' lesson' + (vis.length > 1 ? 's' : '') + '</span>' +
        '</summary>' +
        vis.map(function (e) {
          var title = lessonTitle(e.item);
          var free = ci === 0 && e.first;   /* first lesson of each subject previews free */
          return '<div class="lesson">' +
            '<span class="lesson-n">' + String(e.n).padStart(3, '0') + '</span>' +
            '<span class="lesson-name">' + esc(title) + '</span>' +
            '<span class="lesson-end">' +
              (ELESSONS.showDurations && e.item.d ? '<span class="lesson-dur">' + esc(e.item.d) + '</span>' : '') +
              (free ? '<a class="tag-free" href="#demo" data-preview="' + esc(title) + '">Free preview</a>' : '') +
            '</span></div>';
        }).join('') + '</details>';
    });

    $('register-body').innerHTML = html ||
      '<div class="reg-empty"><p class="h3">No lessons match \u201c' + esc(query) + '\u201d</p>' +
      '<p style="margin-top:.4rem;font-size:.9rem">Try a chapter name, an exercise number, or clear the search.</p></div>';

    var planTot = $('register-plan-total');
    if (planTot) {
      var pn = planLessonCount(S.grade, S.plan, S.subject, S.stream);
      var pStreams = streamsForPlan(S.grade, S.plan, S.subject, S.stream);
      if (S.plan === 'full') {
        var nSubj = pStreams.filter(function (k) {
          return !(STREAM_META[k] && STREAM_META[k].complimentary);
        }).length || pStreams.length;
        planTot.textContent = pn + ' lessons across ' + nSubj + ' subject' + (nSubj === 1 ? '' : 's');
      } else if (S.plan === 'subject') {
        planTot.textContent = pn + ' lessons across ' + pStreams.length +
          ' subject' + (pStreams.length === 1 ? '' : 's');
      } else {
        planTot.textContent = pn ? (pn + ' lessons in the published register') : '';
      }
    }

    var streamLabel = stream && STREAM_META[stream] ? STREAM_META[stream].label : '';
    $('register-summary').textContent = q
      ? hits + ' lesson' + (hits === 1 ? '' : 's') + ' matching \u201c' + query + '\u201d'
      : (streamLabel
          ? (streamLabel + ' \u2014 ' + streamCount(S.grade, stream, null, S.stream) + ' lessons \u00b7 ' + chapters.length + ' chapters')
          : (streamCount(S.grade, stream, null, S.stream) + ' lessons \u00b7 ' + chapters.length + ' chapters'));

    $('register-body').querySelectorAll('[data-preview]').forEach(function (a) {
      a.addEventListener('click', function () { track('preview_click', { lesson: a.dataset.preview, stream: stream }); });
    });
  }

  function bindRegister() {
    /* gtec-ui.js owns aria-selected and the arrow keys for every [role=tablist].
       Observing the attribute keeps this in step with mouse AND keyboard use
       without duplicating that logic here. */
    var bar = $('stream-tabs');
    new MutationObserver(function (muts) {
      muts.forEach(function (m) {
        if (m.attributeName !== 'aria-selected') return;
        if (m.target.getAttribute('aria-selected') !== 'true') return;
        var k = m.target.dataset.stream;
        if (!k || k === stream) return;
        stream = k;
        var box = $('register-search');
        /* Drop a stale search term, otherwise a subject can open on an empty
           list and read as a broken tab. */
        if (box && query) { box.value = ''; query = ''; }
        paintRegister();
        track('register_stream', { stream: stream });
      });
    }).observe(bar, { attributes: true, subtree: true, attributeFilter: ['aria-selected'] });

    var t;
    $('register-search').addEventListener('input', function (e) {
      clearTimeout(t);
      var v = e.target.value;
      t = setTimeout(function () {
        query = v; paintRegister();
        if (v.trim()) track('register_search', { q: v.trim(), stream: stream });
      }, 180);
    });

    $('download-pdf').addEventListener('click', function () {
      track('pdf_download', { grade: S.grade, stream: stream });
    });
  }

  /* ══════════════ TIER TAB -> PLAN ══════════════ */
  function bindTierTabs() {
    var bar = $('tier-tabs');
    new MutationObserver(function (muts) {
      muts.forEach(function (m) {
        if (m.attributeName !== 'aria-selected') return;
        if (m.target.getAttribute('aria-selected') !== 'true') return;
        var v = m.target.dataset.tier;
        if (!v || v === S.plan) return;
        S.plan = v;
        paintHero(); paintPrice(); paintTiers(); paintStreamTabs(); paintRegister(); paintRelated();
        track('tier_tab', { tab: v });
      });
    }).observe(bar, { attributes: true, subtree: true, attributeFilter: ['aria-selected'] });
  }

  /* ══════════════ FAQ / REVIEWS / RELATED ══════════════ */
  function paintFaq() {
    $('faq-list').innerHTML = FAQS.map(function (f) {
      return '<details class="faq"><summary>' + esc(f.q) + '</summary>' +
        '<div class="body">' + esc(f.a) + '</div></details>';
    }).join('');
    var ld = $('ld-faq');
    if (ld) ld.textContent = JSON.stringify({
      '@context': 'https://schema.org', '@type': 'FAQPage',
      mainEntity: FAQS.map(function (f) {
        return { '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } };
      })
    }, null, 1);
  }

  function paintRelated() {
    /* Subject pages: other subjects in the same grade.
       Stream pages: other streams in the same grade.
       Bundle pages: same annual package in other grades. */
    var cards = [];

    if (S.plan === 'subject') {
      subjectsForGrade(S.grade, S.stream).forEach(function (sub) {
        if (sub === S.subject) return;
        cards.push({ grade: S.grade, plan: 'subject', subject: sub, stream: S.stream || null });
      });
      $('related-heading').textContent = 'Other subjects in Grade ' + S.grade +
        (isStreamGrade(S.grade) && S.stream && PACKAGE_META[S.stream]
          ? ' \u00b7 ' + PACKAGE_META[S.stream].name : '') + '.';
    } else if (isStreamGrade(S.grade)) {
      packagesForGrade(S.grade).forEach(function (pkg) {
        if (pkg === S.stream) return;
        cards.push({ grade: S.grade, plan: 'full', stream: pkg });
      });
      $('related-heading').textContent = 'Other Grade ' + S.grade + ' streams.';
    } else {
      Object.keys(PRICING).map(Number).filter(function (g) {
        return g !== S.grade;
      }).slice(0, 4).forEach(function (g) {
        cards.push({ grade: g, plan: 'full', subject: null });
      });
      $('related-heading').textContent = 'Also available.';
    }

    var popularGrade = null;
    var asSubject = !isStreamGrade(S.grade) && S.plan === 'subject';
    if (!asSubject && !isStreamGrade(S.grade)) {
      var grades = cards.map(function (c) { return c.grade; });
      popularGrade = grades.indexOf(9) > -1 ? 9 : (grades.indexOf(10) > -1 ? 10 : grades[0]);
    }
    var popularSubject = asSubject && cards.length
      ? (cards.some(function (c) { return c.subject === 'maths'; }) ? 'maths' : cards[0].subject)
      : null;
    var popularStream = isStreamGrade(S.grade) && cards.length ? cards[0].stream : null;

    $('related-grid').innerHTML = cards.map(function (c) {
      var g = c.grade;
      var sub = c.subject;
      var pkg = c.stream;
      var isSub = c.plan === 'subject';
      var isPkg = !isSub && !!pkg;
      var p = isSub ? planPrice(g, 'subject', S.mode, sub, pkg)
            : isPkg ? planPrice(g, 'full', S.mode, null, pkg)
            : planPrice(g, 'full', S.mode);
      var a = priceAttrs(p);
      var meta = isSub ? SUBJECT_META[sub] : (isPkg ? PACKAGE_META[pkg] : null);
      var banner = isSub ? meta.banner : (isPkg ? meta.banner : 'sb-bundle');
      var colour = isSub ? meta.colour : (isPkg ? meta.colour : (GRADE_TINT[g] || '#073790'));
      var label  = isSub ? meta.name + ' \u2014 ' + meta.tag
                 : isPkg ? meta.name + ' \u2014 ' + meta.tag
                 : 'Maths, Science and English';
      var href   = isPkg
        ? ('course-detail.html?grade=' + g + '&plan=full&stream=' + pkg + '&mode=' + S.mode)
        : isSub && isStreamGrade(g) && pkg
          ? ('course-detail.html?grade=' + g + '&plan=subject&subject=' + sub + '&stream=' + pkg + '&mode=' + S.mode)
        : ('course-detail.html?grade=' + g + '&plan=' + (isSub ? 'subject&subject=' + sub : 'full') + '&mode=' + S.mode);
      var planId = 'g' + g + '-' + (isSub ? sub : (pkg || 'full')) + '-' + S.mode;
      var mrp = (isSub || isPkg) ? null : fullMrp(g);
      var save = mrp ? { inr: mrp.inr - p.inr, aed: mrp.aed - p.aed } : null;
      var micro = isSub
        ? 'Full academic year \u00b7 this subject'
        : isPkg
          ? 'Annual package \u00b7 English Grammar free'
        : (save && save.inr > 0
            ? ('Save ' + priceAttrs(save)[cur()] + ' vs buying subjects separately')
            : 'Full academic year');
      var modeHtml = '<div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Recorded + Mentorship support</span></div>';
      var isPopular = isSub ? (sub === popularSubject)
                    : isPkg ? (pkg === popularStream)
                    : (g === popularGrade);
      return '<article class="rel-card" style="--banner:' + colour + ';--grade-tint:' + colour + '">' +
        '<div class="rel-card__art sub-banner ' + banner + '" role="img" aria-label="' + esc(label) + '">' +
          (isPopular ? '<span class="rel-card__badge">Most popular</span>' : '') +
        '</div>' +
        '<div class="rel-card__body">' +
          '<div><p class="mono card-kicker" style="color:' + colour + '">Grade ' + g +
            ' \u00b7 ' + (isSub ? 'single subject' : isPkg ? 'stream package' : 'all subjects') + '</p>' +
          '<h3 class="h3" style="margin-top:.25rem">' + esc(isSub ? meta.name : isPkg ? meta.name : 'Annual Package') + '</h3></div>' +
          modeHtml +
          '<div><p class="price" data-inr="' + a.inr + '" data-aed="' + a.aed + '" data-usd="' + a.usd + '" ' +
          'style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">' + a.inr + '</p>' +
          '<p class="note-sm">' + esc(micro) + '</p>' +
          '</div>' +
          '<div class="rel-card__actions">' +
            '<button type="button" class="btn btn-red btn-sm btn-block" data-rel-add="' + planId + '" ' +
              'data-grade="' + g + '" data-plan="' + c.plan + '" ' +
              (isSub ? 'data-subject="' + sub + '" ' : '') +
              (isPkg ? 'data-stream="' + pkg + '" ' : '') +
              'data-mode="' + S.mode + '">Add to cart</button>' +
            '<a class="rel-card__details" href="' + href + '" data-plan-link="' + planId + '">View details</a>' +
          '</div>' +
        '</div></article>';
    }).join('');

    var grid = $('related-grid');
    if (!grid) return;
    grid.querySelectorAll('[data-rel-add]').forEach(function (b) {
      b.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var g = Number(b.dataset.grade);
        var plan = b.dataset.plan;
        var sub = b.dataset.subject || null;
        var mode = b.dataset.mode || S.mode;
        var price = plan === 'subject' ? planPrice(g, 'subject', mode, sub) : planPrice(g, 'full', mode);
        var title = plan === 'subject'
          ? ('Grade ' + g + ' \u2014 ' + SUBJECT_META[sub].name)
          : ('Grade ' + g + ' \u2014 Annual Package');
        addCartItem(makeCartItem({
          id: b.dataset.relAdd, type: plan, grade: g, subject: sub, mode: mode,
          title: title,
          subtitle: (mode === 'live' ? 'Recorded + Mentorship support' : 'Recorded') + ' \u00b7 Full academic year',
          price: price
        }));
        track('plan_click', { plan_id: b.dataset.relAdd, mode: mode, action: 'add_to_cart' });
      });
    });
    grid.querySelectorAll('[data-plan-link]').forEach(function (a) {
      a.addEventListener('click', function () { track('plan_click', { plan_id: a.dataset.planLink, mode: S.mode }); });
    });
  }

  /* ══════════════ WHATSAPP / LMS / CHECKOUT ══════════════ */
  function bindWa() {
    document.querySelectorAll('[data-wa]').forEach(function (a) {
      var msg = "Hi GTEC Team, I'm interested in " + a.dataset.wa + '. Can you share more details?';
      a.href = (typeof elWhatsAppHref === 'function')
        ? elWhatsAppHref(msg, cur())
        : ('https://wa.me/' + ELESSONS.whatsapp + '?text=' + encodeURIComponent(msg));
      a.rel = 'noopener';
      a.target = '_blank';
      if (a.dataset.waBound) return;
      a.dataset.waBound = '1';
      a.addEventListener('click', function () {
        track('whatsapp_lead', {
          context: a.dataset.wa, page: location.pathname, currency: cur()
        });
      });
    });
  }
  /* Location-based currency (geo-pricing.js) — refresh WA/cart when it settles. */
  function bindCurrencyWa() {
    if (document.documentElement.dataset.waCurrencyBound === '1') return;
    document.documentElement.dataset.waCurrencyBound = '1';
    document.addEventListener('el:currency', function () {
      bindWa();
      paintCart();
    });
  }
  function bindLms() {
    document.querySelectorAll('[data-lms]').forEach(function (a) {
      a.href = ELESSONS.lmsUrl + '?redirect=' + encodeURIComponent(location.href) +
               '&course=' + encodeURIComponent('g' + S.grade + '-' + S.plan);
      a.addEventListener('click', function () { track('lms_login_click', { course: 'g' + S.grade + '-' + S.plan }); });
    });
  }
  function toast(msg) {
    var el = $('toast');
    el.textContent = msg;
    el.dataset.show = 'true';
    clearTimeout(el._t);
    el._t = setTimeout(function () { el.dataset.show = 'false'; }, 3200);
  }
  function bindBuy() {
    function doBuy(e) {
      if (e) e.preventDefault();
      var buy = $('buy-now');
      if (buy && buy.getAttribute('aria-disabled') === 'true') return;
      addCurrentPlanToCart();
    }
    var buy = $('buy-now');
    if (buy) buy.addEventListener('click', doBuy);
    document.querySelectorAll('[data-add-to-cart]').forEach(function (b) {
      b.addEventListener('click', doBuy);
    });
    var bar = $('bar-buy');
    if (bar) bar.addEventListener('click', function (e) {
      e.preventDefault();
      var sticky = $('stickybar');
      if (sticky && sticky.dataset.mode === 'cart') { openCart(); return; }
      if (bar.getAttribute('aria-disabled') === 'true') return;
      addCurrentPlanToCart();
    });
    var upCta = $('upgrade-cta');
    if (upCta) upCta.addEventListener('click', function () {
      S.plan = 'full';
      paintHero(); paintPrice(); paintTiers(); paintStreamTabs(); paintRegister(); paintRelated(); syncControls();
      track('upgrade_click', { grade: S.grade, subject: S.subject, mode: S.mode });
    });
  }

  function bindStickyPanel() {
    var panel = $('buy-panel');
    if (!panel || typeof IntersectionObserver !== 'function') {
      syncWaFloat();
      return;
    }
    new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        document.body.classList.toggle('panel-gone', !en.isIntersecting);
        scheduleWaFloat();
      });
    }, { threshold: 0, rootMargin: '0px' }).observe(panel);
    scheduleWaFloat();
  }

  /* Pin the WhatsApp FAB above the sticky cart bar, and hide it while the
     buy-panel already shows an "Enquire on WhatsApp" button in the same corner. */
  function stickyBarVisibleHeight(bar) {
    if (!bar) return 0;
    var cs = window.getComputedStyle(bar);
    if (cs.display === 'none' || cs.visibility === 'hidden') return 0;
    if (cs.pointerEvents === 'none') return 0;
    var t = cs.transform;
    if (t && t !== 'none') {
      var parts = t.replace('matrix(', '').replace(')', '').split(',');
      if (parts.length >= 6) {
        var ty = parseFloat(parts[5]);
        if (!isNaN(ty) && Math.abs(ty) > 12) return 0;
      }
    }
    var rect = bar.getBoundingClientRect();
    if (rect.height < 8) return 0;
    /* Allow 1px sub-pixel overflow past the viewport bottom. */
    if (rect.bottom < window.innerHeight - 8) return 0;
    if (rect.top >= window.innerHeight - 4) return 0;
    return Math.ceil(rect.height);
  }

  function syncWaFloat() {
    var fab = document.querySelector('.wa-float');
    if (!fab) return;
    var bar = $('stickybar');
    var stickyH = stickyBarVisibleHeight(bar);
    /* If cart summary is forced on, treat sticky as visible even mid-transition. */
    if (stickyH === 0 && document.body.classList.contains('cart-has-items') && bar) {
      var cs = window.getComputedStyle(bar);
      if (cs.display !== 'none') stickyH = Math.max(64, Math.ceil(bar.getBoundingClientRect().height) || 64);
    }
    if (stickyH === 0 && document.body.classList.contains('panel-gone') && bar) {
      var cs2 = window.getComputedStyle(bar);
      if (cs2.display !== 'none' && cs2.pointerEvents !== 'none') {
        stickyH = Math.max(64, Math.ceil(bar.getBoundingClientRect().height) || 64);
      }
    }
    /* Keep page end (footer) clear of the sticky cart/CTA bar. */
    if (stickyH > 0) {
      document.documentElement.style.setProperty('--stickybar-offset', (stickyH + 20) + 'px');
    } else {
      document.documentElement.style.removeProperty('--stickybar-offset');
    }
    var gap = 20;
    fab.style.setProperty('bottom', (stickyH > 0 ? stickyH + gap : 16) + 'px', 'important');
    fab.style.setProperty('z-index', '100', 'important');

    /* Hide only when the buy-panel WA CTA covers this corner AND no sticky bar. */
    var hide = stickyH === 0 &&
      !document.body.classList.contains('panel-gone') &&
      !document.body.classList.contains('cart-has-items');
    fab.classList.toggle('is-hidden', hide);
    if (!hide) {
      fab.style.setProperty('opacity', '1', 'important');
      fab.style.setProperty('visibility', 'visible', 'important');
      fab.style.setProperty('pointer-events', 'auto', 'important');
    } else {
      fab.style.removeProperty('opacity');
      fab.style.removeProperty('visibility');
      fab.style.removeProperty('pointer-events');
    }
  }

  function scheduleWaFloat() {
    requestAnimationFrame(function () {
      requestAnimationFrame(syncWaFloat);
    });
  }

  /* Controls are static markup, so a URL that sets plan would leave the
     tab bar contradicting the page. Sync them once, before gtec-ui.js
     reads aria-selected to set up roving tabindex. */
  function syncControls() {
    document.querySelectorAll('#tier-tabs .tab').forEach(function (t) {
      if (t.hidden) {
        t.setAttribute('aria-selected', 'false');
        var p = $(t.dataset.panel);
        if (p) p.hidden = true;
        return;
      }
      var on = t.dataset.tier === S.plan;
      t.setAttribute('aria-selected', String(on));
      var panel = $(t.dataset.panel);
      if (panel) panel.hidden = !on;
    });
  }

  /* ---------- go ---------- */
  paintHero();
  paintStreamTabs();
  paintRegister();
  paintTiers();
  paintFaq();
  paintRelated();
  paintPrice();
  syncControls();
  bindMode(); bindTierTabs(); bindRegister(); bindLms(); bindBuy(); bindCartUi(); bindWa();
  bindCurrencyWa();
  bindStickyPanel();
  paintCart();
  scheduleWaFloat();
  window.addEventListener('resize', scheduleWaFloat);
  window.addEventListener('scroll', scheduleWaFloat, { passive: true });
  track('page_view', { page: 'course-detail', grade: S.grade, plan: S.plan, mode: S.mode });
})();
