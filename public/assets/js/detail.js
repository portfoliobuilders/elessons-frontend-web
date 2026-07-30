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

    $('fact-lessons').innerHTML = '<strong>' + registerTotal() + '</strong> video lessons';
    $('fact-chapters').innerHTML = '<strong>' + chapterTotal() + '</strong> chapters';
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

    $('bar-meta').textContent =
      (S.mode === 'live' ? 'Live + Recorded' : 'Recorded') + ' \u00b7 Grade ' + S.grade;

    var dead = S.plan === 'module' && n === 0;
    [$('buy-now'), $('bar-buy')].forEach(function (b) {
      b.setAttribute('aria-disabled', String(dead));
      b.style.opacity = dead ? '.45' : '';
      b.style.pointerEvents = dead ? 'none' : '';
    });

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
      inc: ['Maths, Science and English in full', registerTotal() + ' video lessons across ' + chapterTotal() + ' chapters',
            'Downloadable PDF notes for every chapter', 'Full academic year of LMS access',
            S.mode === 'live' ? 'Weekly live sessions, each one recorded' : 'Watch at your own pace, unlimited replays'],
      cta: 'Choose this package', choose: 'full'
    });

    /* By subject */
    $('tier-subject').innerHTML = subjectsForGrade(g).map(function (sub) {
      var m = SUBJECT_META[sub], p = planPrice(g, 'subject', S.mode, sub);
      var streams = streamsForSubject(sub);
      var count = streams.reduce(function (n, k) { return n + streamCount(k); }, 0);
      return tierCard({
        on: S.plan === 'subject' && S.subject === sub, colour: m.colour,
        kicker: 'Grade ' + g + ' \u00b7 single subject', title: m.name, price: priceAttrs(p),
        note: 'This subject \u00b7 full academic year',
        inc: [m.tag, count + ' video lessons', 'PDF notes for every chapter',
              S.mode === 'live' ? 'Live doubt-clearing included' : 'Recorded lessons, replay anytime'],
        cta: 'Choose ' + m.name, choose: 'subject:' + sub
      });
    }).join('');

    /* By module */
    var mp = planPrice(g, 'module', S.mode);
    $('module-price-note').innerHTML =
      'Each module is <span class="price" data-inr="' + priceAttrs(mp).inr +
      '" data-aed="' + priceAttrs(mp).aed + '">' + priceAttrs(mp).inr + '</span>.';

    $('tier-module-list').innerHTML = Object.keys(STREAM_META).map(function (k) {
      var meta = STREAM_META[k], chs = REGISTER_9[k] || [];
      if (!chs.length) return '';
      return '<details class="mod-sub">' +
        '<summary><span>' + esc(meta.label) + '</span>' +
          '<span class="chip">' + chs.length + ' modules</span></summary>' +
        chs.map(function (ch, ci) {
          var id = k + ':' + ci, on = !!S.modules[id];
          return '<div class="mod-row">' +
            '<p>' + esc(ch.c) + '<br><small>' + publishedLessons(ch).length + ' lessons</small></p>' +
            '<button type="button" class="mod-add" data-module="' + id + '" aria-pressed="' + on + '">' +
              (on ? 'Added' : 'Add') + '</button></div>';
        }).join('') + '</details>';
    }).join('');

    document.querySelectorAll('[data-choose]').forEach(function (b) {
      b.addEventListener('click', function () {
        var v = b.dataset.choose.split(':');
        S.plan = v[0];
        if (v[1]) S.subject = v[1];
        paintHero(); paintPrice(); paintTiers();
        track('plan_select', { plan: S.plan, subject: S.subject, mode: S.mode, grade: S.grade });
        $('buy-panel').scrollIntoView({ behavior: 'smooth', block: 'center' });
      });
    });

    document.querySelectorAll('[data-module]').forEach(function (b) {
      b.addEventListener('click', function () {
        var id = b.dataset.module;
        if (S.modules[id]) { delete S.modules[id]; track('remove_from_cart', { item_id: id }); }
        else { S.modules[id] = true; track('add_to_cart', { item_id: id, currency: cur().toUpperCase() }); }
        b.setAttribute('aria-pressed', String(!!S.modules[id]));
        b.textContent = S.modules[id] ? 'Added' : 'Add';
        if (S.plan !== 'module') { S.plan = 'module'; paintHero(); }
        paintPrice();
      });
    });

    repaint();
  }

  /* ══════════════ VIDEO REGISTER ══════════════ */
  var stream = 'maths', query = '';

  function paintStreamTabs() {
    $('stream-tabs').innerHTML = Object.keys(STREAM_META).map(function (k) {
      return '<button class="tab" role="tab" data-stream="' + k + '" aria-selected="' + (k === stream) + '">' +
        esc(STREAM_META[k].label) + '<small>' + streamCount(k) + ' lessons</small></button>';
    }).join('');
  }

  function paintRegister() {
    var chapters = REGISTER_9[stream] || [];
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
      : streamCount(stream) + ' lessons \u00b7 ' + chapters.length + ' chapters';

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
        paintHero(); paintPrice(); paintTiers();
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
    var others = Object.keys(PRICING).map(Number)
      .filter(function (g) { return g !== S.grade; }).slice(0, 4);
    $('related-grid').innerHTML = others.map(function (g) {
      var p = planPrice(g, 'full', S.mode), a = priceAttrs(p);
      return '<a class="card card-hover course course-img" style="--banner:var(--navy-700)" ' +
        'href="course-detail.html?grade=' + g + '&plan=full&mode=' + S.mode + '" data-plan="g' + g + '-full">' +
        '<span class="sub-banner sb-bundle" role="img" aria-label="Maths, Science and English"></span>' +
        '<div><p class="mono card-kicker" style="color:var(--navy-600)">Grade ' + g + ' \u00b7 all subjects</p>' +
        '<h3 class="h3" style="margin-top:.25rem">Annual Package</h3></div>' +
        '<div class="modes"><span class="mode mode-live"><span class="dot-live"></span>Live classes</span>' +
        '<span class="mode">Recorded lessons</span></div>' +
        '<div style="margin-top:auto"><p class="price" data-inr="' + a.inr + '" data-aed="' + a.aed + '" ' +
        'style="font-weight:800;font-size:1.25rem;color:var(--navy-900);letter-spacing:-.02em">' + a.inr + '</p>' +
        '<p style="color:var(--slate-500);font-size:.75rem">Full academic year</p></div></a>';
    }).join('');
    $('related-grid').querySelectorAll('[data-plan]').forEach(function (a) {
      a.addEventListener('click', function () { track('plan_click', { plan_id: a.dataset.plan, mode: S.mode }); });
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
    [$('buy-now'), $('bar-buy')].forEach(function (b) {
      b.addEventListener('click', function (e) {
        e.preventDefault();
        if (b.getAttribute('aria-disabled') === 'true') return;
        var p = currentPrice();
        track('begin_checkout', {
          value: p[cur()], currency: cur().toUpperCase(), grade: S.grade,
          plan: S.plan, mode: S.mode, items: S.plan === 'module' ? Object.keys(S.modules) : [currentTitle()]
        });
        /* TODO: replace with the real cart route. */
        toast('Checkout is not wired up yet \u2014 this is where the cart opens.');
      });
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
  bindMode(); bindTierTabs(); bindRegister(); bindLms(); bindBuy();
  track('page_view', { page: 'course-detail', grade: S.grade, plan: S.plan, mode: S.mode });
})();
