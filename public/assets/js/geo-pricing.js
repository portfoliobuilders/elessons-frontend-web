/* ==========================================================================
   G-TEC eLessons — location-based pricing
   Detects the shopper's country (IP geolocation), maps it to a price tier
   (INR / AED / USD), and paints every .price element from its authored
   data-inr / data-aed / data-usd attributes. Nothing is FX-converted at
   runtime — each tier is an independent authored list.

   Supported country → tier:
     IN                         → INR
     AE, BH, SA, QA, KW, OM, YE → AED  (GCC + Yemen)
     everything else / unknown  → USD  (fallback)

   Manual picks via .cur-select are remembered in localStorage and win over
   auto-detection until cleared.
   ========================================================================== */
(function (global) {
  'use strict';

  var STORAGE_KEY = 'el-currency';
  var GULF_COUNTRIES = { AE: 1, BH: 1, SA: 1, QA: 1, KW: 1, OM: 1, YE: 1 };
  var GULF_TZ = [
    'Asia/Dubai', 'Asia/Bahrain', 'Asia/Riyadh', 'Asia/Qatar',
    'Asia/Kuwait', 'Asia/Muscat', 'Asia/Aden'
  ];
  var INDIA_TZ = ['Asia/Kolkata', 'Asia/Calcutta'];

  var NOTES = {
    inr: 'India pricing, charged in Indian rupees at checkout.',
    aed: 'Gulf pricing, charged in AED at checkout.',
    usd: 'International pricing, charged in USD at checkout.'
  };

  /* Authored country labels used when syncing pickers that list countries
     (pricing row) vs currencies (nav). Value shape: "cur|CC". */
  function valueFor(cur, country) {
    return cur + '|' + (country || defaultCountry(cur));
  }

  function defaultCountry(cur) {
    if (cur === 'aed') return 'AE';
    if (cur === 'usd') return 'US';
    return 'IN';
  }

  function tierFromCountry(cc) {
    if (!cc) return null;
    var code = String(cc).toUpperCase();
    if (code === 'IN') return valueFor('inr', 'IN');
    if (GULF_COUNTRIES[code]) return valueFor('aed', code === 'AE' ? 'AE' : code);
    return valueFor('usd', code);
  }

  function tierFromTimezone() {
    try {
      var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
      if (GULF_TZ.indexOf(tz) > -1) return valueFor('aed', 'AE');
      if (INDIA_TZ.indexOf(tz) > -1) return valueFor('inr', 'IN');
    } catch (e) { /* ignore */ }
    return valueFor('usd', 'US');
  }

  function readStored() {
    try {
      var v = localStorage.getItem(STORAGE_KEY);
      if (v && /^(inr|aed|usd)\|[A-Z]{2}$/.test(v)) return v;
    } catch (e) { /* ignore */ }
    return null;
  }

  function writeStored(value) {
    try { localStorage.setItem(STORAGE_KEY, value); } catch (e) { /* ignore */ }
  }

  /* IP lookup — try two public endpoints (no API key). Abort quickly so the
     page never waits on a hung geo service. */
  function fetchCountry() {
    var controllers = [];
    function get(url, parse) {
      var ctrl = typeof AbortController === 'function' ? new AbortController() : null;
      if (ctrl) controllers.push(ctrl);
      var timer = setTimeout(function () {
        if (ctrl) try { ctrl.abort(); } catch (e) { /* ignore */ }
      }, 2500);
      return fetch(url, {
        signal: ctrl ? ctrl.signal : undefined,
        credentials: 'omit',
        cache: 'no-store'
      }).then(function (r) {
        if (!r.ok) throw new Error('geo ' + r.status);
        return r.json();
      }).then(function (j) {
        clearTimeout(timer);
        var cc = parse(j);
        if (!cc) throw new Error('no country');
        return String(cc).toUpperCase();
      }, function (err) {
        clearTimeout(timer);
        throw err;
      });
    }

    return Promise.any ? Promise.any([
      get('https://api.country.is/', function (j) { return j && j.country; }),
      get('https://ipwho.is/', function (j) { return j && j.success !== false && j.country_code; }),
      get('https://ipapi.co/json/', function (j) { return j && j.country_code; })
    ]).catch(function () { return null; }) : get(
      'https://api.country.is/',
      function (j) { return j && j.country; }
    ).catch(function () {
      return get('https://ipwho.is/', function (j) {
        return j && j.success !== false && j.country_code;
      }).catch(function () {
        return get('https://ipapi.co/json/', function (j) { return j && j.country_code; })
          .catch(function () { return null; });
      });
    });
  }

  function render(cur) {
    document.querySelectorAll('.price').forEach(function (el) {
      var v = el.dataset[cur];
      if (v) el.textContent = v;
    });
    document.querySelectorAll('.price-note').forEach(function (n) {
      n.textContent = NOTES[cur] || NOTES.usd;
    });
    document.documentElement.setAttribute('data-currency', cur);
    document.documentElement.setAttribute('data-pricing-tier', cur);
  }

  function syncPickers(value) {
    var cur = value.split('|')[0];
    document.querySelectorAll('.cur-select').forEach(function (sel) {
      var i, exact = -1, firstOfCur = -1;
      for (i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value === value) exact = i;
        if (firstOfCur < 0 && sel.options[i].value.split('|')[0] === cur) {
          firstOfCur = i;
        }
      }
      /* Nav lists currencies; pricing lists countries — fall back to the first
         option of the matching currency when there is no exact country match. */
      if (exact > -1 || firstOfCur > -1) {
        sel.selectedIndex = exact > -1 ? exact : firstOfCur;
      }
    });
    render(cur);
  }

  function apply(value, persist) {
    if (!value) value = valueFor('usd', 'US');
    syncPickers(value);
    if (persist) writeStored(value);
    try {
      document.dispatchEvent(new CustomEvent('el:currency', {
        detail: { value: value, currency: value.split('|')[0] }
      }));
    } catch (e) { /* IE / old Safari — ignore */ }
  }

  function bindPickers() {
    document.querySelectorAll('.cur-select').forEach(function (sel) {
      if (sel.dataset.geoBound === '1') return;
      sel.dataset.geoBound = '1';
      sel.addEventListener('change', function () {
        apply(sel.value, true);
      });
    });
  }

  var _detectPromise = null;

  function detectAndApply() {
    bindPickers();

    var stored = readStored();
    if (stored) {
      apply(stored, false);
      return Promise.resolve(stored);
    }

    if (_detectPromise) return _detectPromise;

    /* Paint a timezone guess immediately so prices aren't blank while IP
       resolves, then refine (or leave) once geo returns. */
    var provisional = tierFromTimezone();
    apply(provisional, false);

    _detectPromise = fetchCountry().then(function (cc) {
      if (readStored()) return readStored(); /* user picked while we waited */
      var next = cc ? tierFromCountry(cc) : provisional;
      /* Unsupported / unknown countries land on USD. */
      if (!next) next = valueFor('usd', 'US');
      apply(next, false);
      document.documentElement.setAttribute('data-geo-country', cc || '');
      return next;
    });
    return _detectPromise;
  }

  var api = {
    detectAndApply: detectAndApply,
    apply: apply,
    render: render,
    tierFromCountry: tierFromCountry,
    NOTES: NOTES,
    STORAGE_KEY: STORAGE_KEY
  };

  global.ELessonsGeoPricing = api;

  /* Auto-start when this file is loaded as a classic script. Pages that need
     to delay can set window.EL_GEO_PRICING_MANUAL = true before the tag. */
  if (!global.EL_GEO_PRICING_MANUAL) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function () { detectAndApply(); });
    } else {
      detectAndApply();
    }
  }
})(typeof window !== 'undefined' ? window : this);
