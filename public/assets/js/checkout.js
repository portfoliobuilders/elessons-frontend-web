/* ==========================================================================
   G-TEC eLessons — checkout (WhatsApp handoff)
   Reads the same localStorage cart as course-detail. Card/Razorpay payment
   can replace the WA CTA later without changing the cart format.
   Currency is IP-only via geo-pricing.js — no manual switcher.
   LOAD: course-data.js → checkout.js → geo-pricing.js → gtec-ui.js
   ========================================================================== */
(function () {
  'use strict';

  var CART_KEY = 'elessons_cart_v1';

  function $(id) { return document.getElementById(id); }
  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function cur() {
    return document.documentElement.getAttribute('data-currency') || 'inr';
  }
  function track(event, params) {
    var p = params || {};
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push(Object.assign({ event: event }, p));
    if (typeof window.gtag === 'function') window.gtag('event', event, p);
  }
  function loadCart() {
    try { return JSON.parse(localStorage.getItem(CART_KEY) || '{"items":[]}'); }
    catch (e) { return { items: [] }; }
  }
  function saveCart(cart) {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
  }
  function moneyLabel(price, currency) {
    if (typeof fmtMoney === 'function') {
      return fmtMoney((price && price[currency]) || 0, currency);
    }
    var n = (price && price[currency]) || 0;
    if (currency === 'aed') return 'AED ' + n.toLocaleString('en-AE');
    if (currency === 'omr') return 'OMR ' + n.toLocaleString('en-US');
    if (currency === 'bhd') return 'BHD ' + n.toLocaleString('en-US');
    if (currency === 'qar') return 'QAR ' + n.toLocaleString('en-US');
    if (currency === 'sar') return 'SAR ' + n.toLocaleString('en-US');
    if (currency === 'kwd') return 'KWD ' + n.toLocaleString('en-US');
    if (currency === 'usd') return '$' + n.toLocaleString('en-US');
    return '₹' + n.toLocaleString('en-IN');
  }
  function cartTotal(cart) {
    if (typeof moneyZero === 'function' && typeof addMoney === 'function') {
      return cart.items.reduce(function (t, it) {
        return addMoney(t, it.price || moneyZero());
      }, moneyZero());
    }
    return cart.items.reduce(function (t, it) {
      return {
        inr: t.inr + ((it.price && it.price.inr) || 0),
        aed: t.aed + ((it.price && it.price.aed) || 0),
        usd: t.usd + ((it.price && it.price.usd) || 0)
      };
    }, { inr: 0, aed: 0, usd: 0 });
  }
  function buildMessage(cart, currency, parentName, phone) {
    var lines = [
      "Hi GTEC Team, I'd like to complete my eLessons enrolment.",
      ''
    ];
    if (parentName) lines.push('Parent / guardian: ' + parentName);
    if (phone) lines.push('Phone: ' + phone);
    if (parentName || phone) lines.push('');
    lines.push('Order (' + currency.toUpperCase() + '):');
    cart.items.forEach(function (it, i) {
      lines.push((i + 1) + '. ' + it.title +
        (it.subtitle ? ' — ' + it.subtitle : '') +
        ' · ' + moneyLabel(it.price, currency));
    });
    var tot = cartTotal(cart);
    lines.push('');
    lines.push('Total: ' + moneyLabel(tot, currency));
    lines.push('');
    lines.push('Please confirm availability and share payment instructions.');
    return lines.join('\n');
  }

  function noteFor(currency) {
    var notes = {
      inr: 'India pricing — your counsellor will confirm INR payment.',
      aed: 'UAE pricing — your counsellor will confirm AED payment.',
      omr: 'Oman pricing — your counsellor will confirm OMR payment.',
      bhd: 'Bahrain pricing — your counsellor will confirm BHD payment.',
      qar: 'Qatar pricing — your counsellor will confirm QAR payment.',
      sar: 'Saudi pricing — your counsellor will confirm SAR payment.',
      kwd: 'Kuwait pricing — your counsellor will confirm KWD payment.',
      usd: 'International pricing — your counsellor will confirm USD payment.'
    };
    return notes[currency] || notes.usd;
  }

  function paint() {
    var cart = loadCart();
    var currency = cur();

    var empty = $('co-empty');
    var form = $('co-form');
    var list = $('co-items');
    var totalEl = $('co-total');
    var note = $('co-currency-note');

    if (!cart.items.length) {
      if (empty) empty.hidden = false;
      if (form) form.hidden = true;
      return;
    }
    if (empty) empty.hidden = true;
    if (form) form.hidden = false;

    list.innerHTML = cart.items.map(function (it) {
      return '<li class="co-item">' +
        '<div><p class="co-item-title">' + esc(it.title) + '</p>' +
        (it.subtitle ? '<p class="note-sm">' + esc(it.subtitle) + '</p>' : '') +
        '</div>' +
        '<div class="co-item-side">' +
        '<span class="price" ' +
        ((typeof CURRENCY_KEYS !== 'undefined' ? CURRENCY_KEYS : ['inr','aed','usd']).map(function (k) {
          return 'data-' + k + '="' + esc(moneyLabel(it.price, k)) + '"';
        }).join(' ')) + '>' +
        esc(moneyLabel(it.price, currency)) + '</span>' +
        '<button type="button" class="co-remove" data-remove="' + esc(it.id) +
        '" aria-label="Remove ' + esc(it.title) + '">Remove</button>' +
        '</div></li>';
    }).join('');

    var tot = cartTotal(cart);
    if (totalEl) {
      (typeof CURRENCY_KEYS !== 'undefined' ? CURRENCY_KEYS : ['inr','aed','usd']).forEach(function (k) {
        totalEl.dataset[k] = moneyLabel(tot, k);
      });
      totalEl.classList.add('price');
      totalEl.textContent = moneyLabel(tot, currency);
    }
    if (note) note.textContent = noteFor(currency);

    list.querySelectorAll('[data-remove]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var next = loadCart();
        next.items = next.items.filter(function (it) { return it.id !== btn.dataset.remove; });
        saveCart(next);
        track('remove_from_cart', { item_id: btn.dataset.remove });
        paint();
      });
    });

    syncWa();
  }

  function syncWa() {
    var cart = loadCart();
    var currency = cur();
    var name = ($('co-name') && $('co-name').value.trim()) || '';
    var phone = ($('co-phone') && $('co-phone').value.trim()) || '';
    var msg = buildMessage(cart, currency, name, phone);
    var href = (typeof elWhatsAppHref === 'function')
      ? elWhatsAppHref(msg, currency)
      : ('https://wa.me/' + ELESSONS.whatsapp + '?text=' + encodeURIComponent(msg));
    var cta = $('co-wa');
    if (cta) {
      cta.href = href;
      cta.rel = 'noopener';
      cta.target = '_blank';
    }
  }

  function bind() {
    ['co-name', 'co-phone'].forEach(function (id) {
      var el = $(id);
      if (el) el.addEventListener('input', syncWa);
    });
    var cta = $('co-wa');
    if (cta) {
      cta.addEventListener('click', function () {
        var cart = loadCart();
        if (!cart.items.length) return;
        var tot = cartTotal(cart);
        track('begin_checkout', {
          value: tot[cur()], currency: cur().toUpperCase(),
          items: cart.items.map(function (it) { return it.id; }),
          method: 'whatsapp'
        });
        track('whatsapp_lead', { context: 'checkout', currency: cur() });
      });
    }
    /* Refresh totals when geo-pricing settles the market. */
    document.addEventListener('el:currency', function () { paint(); });
  }

  paint();
  bind();
  track('page_view', { page: 'checkout', currency: cur(), items: loadCart().items.length });
})();
