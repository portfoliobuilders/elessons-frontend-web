/* ==========================================================================
   G-TEC eLessons — course detail page logic

   LOAD ORDER MATTERS: course-data.js -> detail.js -> gtec-ui.js
   This file renders synchronously so that by the time gtec-ui.js runs, every
   tab, price and disclosure it needs to bind already exists in the DOM.

   Prices are never converted here. Each .price element carries BOTH authored
   figures as data-inr / data-aed, exactly as indexnew.html does, and the
   shared switcher decides which one is shown.
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

  /* Single analytics choke point — wire GTM once, don't scatter tags. */
  function track(event, params) {
    var p = params || {};
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push(Object.assign({ event: event }, p));
    if (typeof window.gtag === 'function') window.gtag('event', event, p);
  }
  window.elTrack = track;


  /* ══════════════ CART (localStorage) ══════════════
     Brochure → store: parents can bundle packages, subjects and modules
     without losing context. Checkout still toast-stubs until a payment route
     exists — but the cart itself is real and survives reloads. */
  var CART_KEY = 'elessons_cart_v1';
  var GRADE_TINT = { 8: '#0D7377', 9: '#073790', 10: '#5B3E96', 11: '#9A3412', 12: '#1B6A47' };
  /* PLACEHOLDER enrolment figures for related cards — replace with real counts. */
  var GRADE_ENROLLED = { 8: 2100, 9: 4200, 10: 3800, 11: 1900, 12: 1600 };

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
      price: { inr: partial.price.inr, aed: partial.price.aed }
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
    /* Keep module picker buttons in sync if we removed a module line. */
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
          '<p class="cart-line__meta">' + esc(it.subtitle || ((it.mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' · Grade ' + it.grade)) + '</p></div>' +
          '<p class="cart-line__price price" data-inr="' + a.inr + '" data-aed="' + a.aed + '">' + a[cur()] + '</p>' +
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
        (S.mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' \u00b7 Grade ' + S.grade;
      $('bar-buy').textContent = 'Add to cart';
      var dead = S.plan === 'module' && moduleCount() === 0;
      $('bar-buy').setAttribute('aria-disabled', String(dead));
      $('bar-buy').style.opacity = dead ? '.45' : '';
      $('bar-buy').style.pointerEvents = dead ? 'none' : '';
    }

    /* Module rail summary */
    paintModRail();
    repaint();
  }

  function paintModRail() {
    var n = moduleCount();
    var countEl = $('mod-rail-count');
    var totalEl = $('mod-rail-total');
    var hint = $('mod-rail-hint');
    var addBtn = $('mod-rail-add');
    if (!countEl) return;
    countEl.textContent = n + ' module' + (n === 1 ? '' : 's');
    var mp = planPrice(S.grade, 'module', S.mode);
    setPrice(totalEl, mulMoney(mp, n));
    if (hint) {
      hint.textContent = n
        ? 'Ready to add this selection to your cart.'
        : 'Pick chapters below to build your own pack.';
    }
    if (addBtn) addBtn.disabled = n === 0;
  }

  function currentCartId() {
    if (S.plan === 'full') return 'g' + S.grade + '-full-' + S.mode;
    if (S.plan === 'subject') return 'g' + S.grade + '-' + S.subject + '-' + S.mode;
    return null; /* modules are added individually */
  }

  function addCurrentPlanToCart() {
    if (S.plan === 'module') {
      var ids = Object.keys(S.modules);
      if (!ids.length) { toast('Select at least one module first'); return; }
      var mp = planPrice(S.grade, 'module', S.mode);
      var added = 0;
      ids.forEach(function (mid) {
        var parts = mid.split(':');
        var stream = parts[0];
        var ci = Number(parts[1]);
        var chs = streamChapters(S.grade, stream);
        var ch = chs[ci];
        if (!ch) return;
        var id = 'g' + S.grade + '-mod-' + mid + '-' + S.mode;
        if (cartHas(id)) return;
        addCartItem(makeCartItem({
          id: id, type: 'module', grade: S.grade, mode: S.mode,
          title: ch.c,
          subtitle: 'Grade ' + S.grade + ' · ' + (STREAM_META[stream] ? STREAM_META[stream].label : stream) +
                    ' · ' + (S.mode === 'live' ? 'Live + Recorded' : 'Recorded'),
          price: mp
        }), { open: false });
        added++;
      });
      if (added) { openCart(); toast(added + ' module' + (added === 1 ? '' : 's') + ' added to cart'); }
      else { toast('Those modules are already in your cart'); openCart(); }
      return;
    }
    var p = currentPrice();
    var id = currentCartId();
    addCartItem(makeCartItem({
      id: id, type: S.plan, grade: S.grade, subject: S.plan === 'subject' ? S.subject : null,
      mode: S.mode, title: currentTitle(),
      subtitle: (S.mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' · Full academic year',
      price: p
    }));
  }

  function bindCartUi() {
    var openers = ['cart-open', 'mod-rail-open'];
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
      var tot = cartTotal(cart);
      track('begin_checkout', {
        value: tot[cur()], currency: cur().toUpperCase(),
        items: cart.items.map(function (it) { return it.id; })
      });
      /* TODO: replace with the real checkout route. */
      toast('Checkout is not wired up yet — this is where payment starts.');
    });
    var railAdd = $('mod-rail-add');
    if (railAdd) railAdd.addEventListener('click', function () {
      S.plan = 'module';
      addCurrentPlanToCart();
    });
  }

  /* Writes both authored figures, then shows the active one. */
  function setPrice(el, money) {
    if (!el) return;
    var a = priceAttrs(money);
    el.dataset.inr = a.inr;
    el.dataset.aed = a.aed;
    el.textContent = a[cur()];
  }
  /* Re-runs the shared switcher so every .price repaints from its datasets. */
  function repaint() {
    var sel = document.querySelector('.cur-select');
    if (sel) sel.dispatchEvent(new Event('change'));
  }

  var ICON_TICK = '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>';

  /* ---------- state from the URL ---------- */
  var qp = new URLSearchParams(location.search);
  var S = {
    grade:   PRICING[qp.get('grade')] ? Number(qp.get('grade')) : 9,
    plan:    ['full', 'subject', 'module'].indexOf(qp.get('plan')) > -1 ? qp.get('plan') : 'full',
    subject: null,
    mode:    qp.get('mode') === 'live' ? 'live' : 'recorded',
    modules: {}
  };
  var subs = subjectsForGrade(S.grade);
  S.subject = subs.indexOf(qp.get('subject')) > -1 ? qp.get('subject') : subs[0];

  /* ---------- current price ---------- */
  function moduleCount() { return Object.keys(S.modules).length; }
  function currentPrice() {
    if (S.plan === 'module') {
      return mulMoney(planPrice(S.grade, 'module', S.mode), moduleCount());
    }
    return planPrice(S.grade, S.plan, S.mode, S.subject);
  }
  function currentTitle() {
    if (S.plan === 'subject') return 'Grade ' + S.grade + ' \u2014 ' + SUBJECT_META[S.subject].name;
    if (S.plan === 'module')  return 'Grade ' + S.grade + ' \u2014 Build your own';
    return 'Grade ' + S.grade + ' \u2014 Annual Package';
  }
  function waContext() { return currentTitle().replace(/\u2014/g, '-'); }

  /* ══════════════ HERO ══════════════ */
  function paintHero() {
    var t = currentTitle();
    $('course-title').textContent = t;
    $('crumb-current').textContent = t;
    document.title = t + ' | G-TEC eLessons.net';

    var banner = S.plan === 'subject' ? SUBJECT_META[S.subject].banner : 'sb-bundle';
    var art = $('hero-art');
    art.className = 'dhero-art sub-banner ' + banner;
    art.style.margin = '0';
    art.setAttribute('aria-label', S.plan === 'subject'
      ? SUBJECT_META[S.subject].name + ' \u2014 ' + SUBJECT_META[S.subject].tag
      : 'Maths, Science and English');

    $('course-lede').textContent = S.plan === 'subject'
      ? SUBJECT_META[S.subject].blurb
      : S.plan === 'module'
        ? 'Pick only the chapters you need. Every module is priced on its own and lands in your library the moment you buy it.'
        : 'Maths, Science and English together for grade ' + S.grade +
          ' \u2014 every lesson and every notes file, unlocked on day one.';

    /* Counts must describe THIS purchase, not the whole catalog, and must not
       borrow another grade's syllabus. */
    var lc = $('fact-lessons'), cc = $('fact-chapters');
    if (hasRegister(S.grade)) {
      var n = planLessonCount(S.grade, S.plan, S.subject);
      var c = planChapterCount(S.grade, S.plan, S.subject);
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
    if (S.plan === 'full') {
      var mrp = fullMrp(S.grade);
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

    var n = moduleCount();
    $('buy-unit').textContent =
      S.plan === 'module'
        ? (n ? n + ' module' + (n > 1 ? 's' : '') + ' selected' : 'No modules selected yet')
        : S.plan === 'subject' ? 'This subject \u00b7 full academic year'
                               : 'All three subjects \u00b7 full academic year';

    var bar = $('stickybar');
    if (!bar || bar.dataset.mode !== 'cart') {
      $('bar-meta').textContent =
        (S.mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' \u00b7 Grade ' + S.grade;
      $('bar-buy').textContent = 'Add to cart';
      var dead = S.plan === 'module' && n === 0;
      [$('buy-now'), $('bar-buy')].forEach(function (b) {
        if (!b) return;
        b.setAttribute('aria-disabled', String(dead));
        b.style.opacity = dead ? '.45' : '';
        b.style.pointerEvents = dead ? 'none' : '';
      });
    }
    paintModRail();

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
      j.offers.priceCurrency = cur() === 'aed' ? 'AED' : 'INR';
      el.textContent = JSON.stringify(j, null, 1);
    } catch (e) { /* schema is decorative; never let it break the page */ }
  }

  /* ══════════════ MODE SEGMENTED CONTROL ══════════════ */
  function bindMode() {
    document.querySelectorAll('#seg-mode button').forEach(function (b) {
      b.addEventListener('click', function () {
        if (S.mode === b.dataset.mode) return;
        S.mode = b.dataset.mode;
        document.querySelectorAll('#seg-mode button').forEach(function (o) {
          o.setAttribute('aria-checked', String(o.dataset.mode === S.mode));
        });
        paintPrice(); paintTiers();
        track('mode_change', { mode: S.mode, grade: S.grade, plan: S.plan });
      });
    });
  }

  /* ══════════════ PURCHASE TIERS ══════════════ */
  function tierCard(opts) {
    return '<article class="tier' + (opts.on ? ' tier-on' : '') + '">' +
      '<p class="mono card-kicker" style="color:' + opts.colour + '">' + esc(opts.kicker) + '</p>' +
      '<h3 class="h3">' + esc(opts.title) + '</h3>' +
      '<p class="price tier-price" data-inr="' + opts.price.inr + '" data-aed="' + opts.price.aed + '">' + opts.price.inr + '</p>' +
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

    /* Full package */
    var fp = planPrice(g, 'full', S.mode), mrp = fullMrp(g);
    $('tier-full').innerHTML = tierCard({
      on: S.plan === 'full', colour: 'var(--navy-600)', kicker: 'Best value \u00b7 all subjects',
      title: 'Grade ' + g + ' Annual Package', price: priceAttrs(fp),
      note: 'Save ' + fmtMoney(mrp.inr - fp.inr, 'inr') + ' against buying separately',
      inc: ['Maths, Science and English in full',
            hasRegister(g) ? registerTotal(g) + ' video lessons across ' + chapterTotal(g) + ' chapters'
                           : 'Every chapter of the CBSE / NCERT syllabus',
            'Downloadable PDF notes for every chapter', 'Full academic year of LMS access',
            S.mode === 'live' ? 'Weekly live sessions, each one recorded' : 'Watch at your own pace, unlimited replays'],
      cta: 'Choose this package', choose: 'full'
    });

    /* By subject */
    $('tier-subject').innerHTML = subjectsForGrade(g).map(function (sub) {
      var m = SUBJECT_META[sub], p = planPrice(g, 'subject', S.mode, sub);
      var count = planLessonCount(g, 'subject', sub);
      return tierCard({
        on: S.plan === 'subject' && S.subject === sub, colour: m.colour,
        kicker: 'Grade ' + g + ' \u00b7 single subject', title: m.name, price: priceAttrs(p),
        note: 'This subject \u00b7 full academic year',
        inc: [m.tag, hasRegister(g) ? count + ' video lessons' : 'Every chapter of this subject',
              'PDF notes for every chapter',
              S.mode === 'live' ? 'Live doubt-clearing included' : 'Recorded lessons, replay anytime'],
        cta: 'Choose ' + m.name, choose: 'subject:' + sub
      });
    }).join('');

    /* By module */
    var mp = planPrice(g, 'module', S.mode);
    var mpa = priceAttrs(mp);
    $('module-price-note').innerHTML =
      'Each module is <span class="price" data-inr="' + mpa.inr +
      '" data-aed="' + mpa.aed + '">' + mpa.inr + '</span>. Use Add all to grab a whole subject in one click.';

    var streams = registerStreams(g);
    if (!streams.length) {
      $('tier-module-list').innerHTML =
        '<div class="reg-empty"><p class="h3">Module list for Grade ' + g + ' is being published</p>' +
        '<p style="margin-top:.4rem;font-size:.9rem">Message us on WhatsApp and we will share the chapter list.</p></div>';
    } else {
      $('tier-module-list').innerHTML = streams.map(function (k) {
        var meta = STREAM_META[k], chs = streamChapters(g, k);
        if (!chs.length) return '';
        return '<details class="mod-sub" style="--stream-colour:' + meta.colour + '"' + (k === streams[0] ? ' open' : '') + '>' +
          '<summary>' +
            '<span class="mod-sub__ico" aria-hidden="true">' + esc(meta.code) + '</span>' +
            '<span>' + esc(meta.label) + '</span>' +
            '<span class="mod-sub__actions">' +
              '<span class="chip">' + chs.length + ' modules</span>' +
              '<button type="button" class="mod-add-all" data-add-all="' + k + '">Add all ' + chs.length + '</button>' +
            '</span>' +
          '</summary>' +
          chs.map(function (ch, ci) {
            var id = k + ':' + ci, on = !!S.modules[id];
            var cartId = 'g' + g + '-mod-' + id + '-' + S.mode;
            var inCart = cartHas(cartId);
            var label = on || inCart
              ? (inCart ? 'Added \u2713' : 'Selected')
              : ('Add to cart \u2014 ' + mpa[cur()]);
            return '<div class="mod-row">' +
              '<p>' + esc(ch.c) + '<br><small>' + publishedLessons(ch).length + ' lessons</small></p>' +
              '<button type="button" class="mod-add" data-module="' + id + '" aria-pressed="' + (on || inCart) + '">' +
                label + '</button></div>';
          }).join('') + '</details>';
      }).join('');
    }

    document.querySelectorAll('[data-choose]').forEach(function (b) {
      b.addEventListener('click', function () {
        var v = b.dataset.choose.split(':');
        S.plan = v[0];
        if (v[1]) S.subject = v[1];
        paintHero(); paintPrice(); paintTiers(); paintStreamTabs(); paintRegister(); paintRelated(); syncControls();
        track('plan_select', { plan: S.plan, subject: S.subject, mode: S.mode, grade: S.grade });
        $('buy-panel').scrollIntoView({ behavior: 'smooth', block: 'center' });
      });
    });

    document.querySelectorAll('[data-module]').forEach(function (b) {
      b.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var id = b.dataset.module;
        var parts = id.split(':');
        var stream = parts[0];
        var ci = Number(parts[1]);
        var ch = (streamChapters(S.grade, stream) || [])[ci];
        var cartId = 'g' + S.grade + '-mod-' + id + '-' + S.mode;
        if (cartHas(cartId) || S.modules[id]) {
          if (cartHas(cartId)) removeCartItem(cartId);
          delete S.modules[id];
        } else {
          S.modules[id] = true;
          if (ch) {
            addCartItem(makeCartItem({
              id: cartId, type: 'module', grade: S.grade, mode: S.mode,
              title: ch.c,
              subtitle: 'Grade ' + S.grade + ' \u00b7 ' + (STREAM_META[stream] ? STREAM_META[stream].label : stream) +
                        ' \u00b7 ' + (S.mode === 'live' ? 'Live + Recorded' : 'Recorded'),
              price: mp
            }), { open: false });
          }
        }
        if (S.plan !== 'module') { S.plan = 'module'; paintHero(); syncControls(); }
        paintModRail();
        paintPrice();
        paintTiers();
      });
    });

    document.querySelectorAll('[data-add-all]').forEach(function (b) {
      b.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var k = b.dataset.addAll;
        var chs = streamChapters(S.grade, k);
        chs.forEach(function (ch, ci) { S.modules[k + ':' + ci] = true; });
        if (S.plan !== 'module') { S.plan = 'module'; paintHero(); syncControls(); }
        /* Add each to cart */
        var added = 0;
        chs.forEach(function (ch, ci) {
          var mid = k + ':' + ci;
          var cartId = 'g' + S.grade + '-mod-' + mid + '-' + S.mode;
          if (cartHas(cartId)) return;
          addCartItem(makeCartItem({
            id: cartId, type: 'module', grade: S.grade, mode: S.mode,
            title: ch.c,
            subtitle: 'Grade ' + S.grade + ' \u00b7 ' + STREAM_META[k].label +
                      ' \u00b7 ' + (S.mode === 'live' ? 'Live + Recorded' : 'Recorded'),
            price: mp
          }), { open: false });
          added++;
        });
        paintPrice(); paintTiers();
        if (added) { openCart(); toast(added + ' modules added'); }
        else { toast('Those modules are already in your cart'); openCart(); }
      });
    });

    paintModRail();
    repaint();
  }

  /* ══════════════ VIDEO REGISTER ══════════════ */
  var stream = null, query = '';

  function planStreams() { return streamsForPlan(S.grade, S.plan, S.subject); }

  function paintStreamTabs() {
    var keys = planStreams();
    if (keys.indexOf(stream) === -1) stream = keys[0] || null;
    $('stream-tabs').hidden = keys.length < 2;
    $('stream-tabs').innerHTML = keys.map(function (k) {
      return '<button class="tab" role="tab" data-stream="' + k + '" aria-selected="' + (k === stream) + '">' +
        esc(STREAM_META[k].label) + '<small>' + streamCount(S.grade, k) + ' lessons</small></button>';
    }).join('');

    /* When only one subject is being bought, say what the full package adds
       rather than silently hiding the rest of the catalog. */
    var up = $('register-upsell');
    var hidden = registerStreams(S.grade).filter(function (k) { return keys.indexOf(k) === -1; });
    if (S.plan === 'subject' && hidden.length && hasRegister(S.grade)) {
      var extra = hidden.reduce(function (n, k) { return n + streamCount(S.grade, k); }, 0);
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
    /* No published class list for this grade: say so plainly instead of
       showing another grade's chapters. */
    if (!hasRegister(S.grade)) {
      $('register-body').innerHTML =
        '<div class="reg-empty"><p class="h3">The Grade ' + S.grade + ' class list is being published</p>' +
        '<p style="margin-top:.5rem;font-size:.9rem;max-width:52ch;margin-inline:auto">Lesson titles for this ' +
        'grade are not on the site yet. The syllabus follows the same CBSE / NCERT sequence \u2014 message us and ' +
        'we will send the chapter list for Grade ' + S.grade + '.</p>' +
        '<a class="btn btn-red btn-sm mt3" data-wa="Grade ' + S.grade + ' class list" href="#">Ask for the class list</a></div>';
      $('register-summary').textContent = 'Class list coming soon';
      $('register-search').hidden = true;
      $('download-pdf').hidden = true;
      bindWa();
      return;
    }
    $('register-search').hidden = false;
    $('download-pdf').hidden = false;

    var chapters = stream ? streamChapters(S.grade, stream) : [];
    var q = query.trim().toLowerCase();
    var running = 0, hits = 0, html = '';

    chapters.forEach(function (ch, ci) {
      /* Bind the true running position BEFORE filtering: titles repeat inside a
         chapter ("Solved Problems" three times in Force and Laws of Motion), so
         an indexOf lookup would give two rows the same number. */
      var lessons = publishedLessons(ch).map(function (l, i) {
        return { item: l, n: running + i + 1, first: i === 0 };
      });
      running += lessons.length;

      var vis = q ? lessons.filter(function (e) {
        return lessonTitle(e.item).toLowerCase().indexOf(q) > -1 || ch.c.toLowerCase().indexOf(q) > -1;
      }) : lessons;
      if (!vis.length) return;
      hits += vis.length;

      html += '<details class="chap"' + (q || ci === 0 ? ' open' : '') + '>' +
        '<summary><span class="chap-n">' + String(ci + 1).padStart(2, '0') + '</span>' +
          '<span>' + esc(ch.c) + '</span>' +
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

    $('register-summary').textContent = q
      ? hits + ' lesson' + (hits === 1 ? '' : 's') + ' matching \u201c' + query + '\u201d'
      : streamCount(S.grade, stream) + ' lessons \u00b7 ' + chapters.length + ' chapters';

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
    /* Same product shape in other grades, with unique grade tint + Add to cart. */
    var asSubject = S.plan === 'subject';
    var others = Object.keys(PRICING).map(Number).filter(function (g) {
      return g !== S.grade && (!asSubject || subjectsForGrade(g).indexOf(S.subject) > -1);
    }).slice(0, 4);

    $('related-heading').textContent = asSubject
      ? SUBJECT_META[S.subject].name + ' in other grades.'
      : 'Also available.';

    var popular = others.indexOf(9) > -1 ? 9 : (others.indexOf(10) > -1 ? 10 : others[0]);

    $('related-grid').innerHTML = others.map(function (g) {
      var p = asSubject ? planPrice(g, 'subject', S.mode, S.subject) : planPrice(g, 'full', S.mode);
      var a = priceAttrs(p);
      var meta = asSubject ? SUBJECT_META[S.subject] : null;
      var banner = asSubject ? meta.banner : 'sb-bundle';
      var colour = asSubject ? meta.colour : (GRADE_TINT[g] || '#073790');
      var label  = asSubject ? meta.name + ' \u2014 ' + meta.tag : 'Maths, Science and English';
      var href   = 'course-detail.html?grade=' + g + '&plan=' + (asSubject ? 'subject&subject=' + S.subject : 'full') + '&mode=' + S.mode;
      var planId = 'g' + g + '-' + (asSubject ? S.subject : 'full') + '-' + S.mode;
      var mrp = asSubject ? null : fullMrp(g);
      var save = mrp ? { inr: mrp.inr - p.inr, aed: mrp.aed - p.aed } : null;
      var modP = planPrice(g, 'module', 'recorded');
      var enrolled = GRADE_ENROLLED[g] ? GRADE_ENROLLED[g].toLocaleString('en-IN') + '+ students enrolled' : '';
      var micro = asSubject
        ? 'Full academic year \u00b7 this subject'
        : (save && save.inr > 0
            ? (priceAttrs(modP)[cur()] + '/module separately \u00b7 Save ' + priceAttrs(save)[cur()])
            : 'Full academic year');
      return '<article class="rel-card" style="--banner:' + colour + ';--grade-tint:' + colour + '">' +
        '<div class="rel-card__art sub-banner ' + banner + '" role="img" aria-label="' + esc(label) + '">' +
          (g === popular ? '<span class="rel-card__badge">Most popular</span>' : '') +
        '</div>' +
        '<div class="rel-card__body">' +
          '<div><p class="mono card-kicker" style="color:' + colour + '">Grade ' + g +
            ' \u00b7 ' + (asSubject ? 'single subject' : 'all subjects') + '</p>' +
          '<h3 class="h3" style="margin-top:.25rem">' + esc(asSubject ? meta.name : 'Annual Package') + '</h3></div>' +
          '<div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span>' +
          '<span class="mode">Recorded lessons</span></div>' +
          '<div><p class="price" data-inr="' + a.inr + '" data-aed="' + a.aed + '" ' +
          'style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">' + a.inr + '</p>' +
          '<p class="note-sm">' + esc(micro) + '</p>' +
          (enrolled ? '<p class="note-sm">' + esc(enrolled) + '</p>' : '') +
          '</div>' +
          '<div class="rel-card__actions">' +
            '<button type="button" class="btn btn-red btn-sm btn-block" data-rel-add="' + planId + '" ' +
              'data-grade="' + g + '" data-plan="' + (asSubject ? 'subject' : 'full') + '" ' +
              (asSubject ? 'data-subject="' + S.subject + '" ' : '') +
              'data-mode="' + S.mode + '">Add to cart</button>' +
            '<a class="btn btn-ghost-dark btn-sm btn-block" href="' + href + '" data-plan-link="' + planId + '">View details</a>' +
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
          subtitle: (mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' \u00b7 Full academic year',
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
      a.href = 'https://wa.me/' + ELESSONS.whatsapp + '?text=' + encodeURIComponent(msg);
      a.rel = 'noopener';
      a.target = '_blank';
      if (a.dataset.waBound) return;
      a.dataset.waBound = '1';
      a.addEventListener('click', function () {
        track('whatsapp_lead', { context: a.dataset.wa, page: location.pathname });
      });
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
    var buy = $('buy-now');
    if (buy) buy.addEventListener('click', function (e) {
      e.preventDefault();
      if (buy.getAttribute('aria-disabled') === 'true') return;
      addCurrentPlanToCart();
    });
    var bar = $('bar-buy');
    if (bar) bar.addEventListener('click', function (e) {
      e.preventDefault();
      var sticky = $('stickybar');
      if (sticky && sticky.dataset.mode === 'cart') { openCart(); return; }
      if (bar.getAttribute('aria-disabled') === 'true') return;
      addCurrentPlanToCart();
    });
  }

  /* Controls are static markup, so a URL that sets plan or mode would leave the
     tab bar and the segmented control contradicting the page. Sync them once,
     before gtec-ui.js reads aria-selected to set up roving tabindex. */
  /* Controls are static markup, so a URL that sets plan or mode would leave the
     tab bar and the segmented control contradicting the page. Sync them once,
     before gtec-ui.js reads aria-selected to set up roving tabindex. */
  function syncControls() {
    document.querySelectorAll('#tier-tabs .tab').forEach(function (t) {
      var on = t.dataset.tier === S.plan;
      t.setAttribute('aria-selected', String(on));
      var panel = $(t.dataset.panel);
      if (panel) panel.hidden = !on;
    });
    document.querySelectorAll('#seg-mode button').forEach(function (b) {
      b.setAttribute('aria-checked', String(b.dataset.mode === S.mode));
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
  paintCart();
  track('page_view', { page: 'course-detail', grade: S.grade, plan: S.plan, mode: S.mode });
})();
