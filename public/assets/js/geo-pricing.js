/* ==========================================================================
   G-TEC eLessons — location-based pricing (automatic only)
   Detects the shopper's country via IP geolocation, maps it to a price tier
   (INR / AED / USD), and paints every .price element from its authored
   data-inr / data-aed / data-usd attributes. Nothing is FX-converted at
   runtime — each tier is an independent authored list.

   There is NO manual currency switcher. Price tier is always derived from
   country (IP), with timezone as a short provisional guess while geo loads.

   Supported country → tier:
     IN                         → INR
     AE, BH, SA, QA, KW, OM, YE → AED  (GCC + Yemen)
     everything else / unknown  → USD  (fallback)
   ========================================================================== */
(function (global) {
  'use strict';

  var LEGACY_STORAGE_KEY = 'el-currency';
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

  var MARKET_LABELS = {
    inr: 'India · ₹ INR',
    aed: 'UAE & Gulf · AED',
    usd: 'International · $ USD'
  };

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

  /* Clear any leftover manual-override key from older builds. */
  function clearLegacyOverride() {
    try { localStorage.removeItem(LEGACY_STORAGE_KEY); } catch (e) { /* ignore */ }
  }

  function fetchCountry() {
    function get(url, parse) {
      var ctrl = typeof AbortController === 'function' ? new AbortController() : null;
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

  function marketLabel(cur, country) {
    if (cur === 'aed' && country && country !== 'AE' && GULF_COUNTRIES[country]) {
      var names = {
        BH: 'Bahrain', SA: 'Saudi Arabia', QA: 'Qatar',
        KW: 'Kuwait', OM: 'Oman', YE: 'Yemen'
      };
      return (names[country] || country) + ' · AED';
    }
    return MARKET_LABELS[cur] || MARKET_LABELS.usd;
  }

  function render(cur, country) {
    document.querySelectorAll('.price').forEach(function (el) {
      var v = el.dataset[cur];
      if (v) el.textContent = v;
    });
    document.querySelectorAll('.price-note').forEach(function (n) {
      n.textContent = NOTES[cur] || NOTES.usd;
    });
    document.querySelectorAll('.cur-market').forEach(function (el) {
      el.textContent = marketLabel(cur, country);
    });
    document.documentElement.setAttribute('data-currency', cur);
    document.documentElement.setAttribute('data-pricing-tier', cur);
    if (country) document.documentElement.setAttribute('data-geo-country', country);
  }

  function apply(value) {
    if (!value) value = valueFor('usd', 'US');
    var parts = value.split('|');
    var cur = parts[0];
    var country = parts[1] || defaultCountry(cur);
    render(cur, country);
    try {
      document.dispatchEvent(new CustomEvent('el:currency', {
        detail: { value: value, currency: cur, country: country }
      }));
    } catch (e) { /* ignore */ }
  }

  var _detectPromise = null;

  function detectAndApply() {
    clearLegacyOverride();
    if (_detectPromise) return _detectPromise;

    var provisional = tierFromTimezone();
    apply(provisional);

    _detectPromise = fetchCountry().then(function (cc) {
      var next = cc ? tierFromCountry(cc) : provisional;
      if (!next) next = valueFor('usd', 'US');
      apply(next);
      document.documentElement.setAttribute('data-geo-country', cc || '');
      return next;
    });
    return _detectPromise;
  }

  global.ELessonsGeoPricing = {
    detectAndApply: detectAndApply,
    apply: apply,
    render: render,
    tierFromCountry: tierFromCountry,
    NOTES: NOTES,
    MARKET_LABELS: MARKET_LABELS
  };

  if (!global.EL_GEO_PRICING_MANUAL) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function () { detectAndApply(); });
    } else {
      detectAndApply();
    }
  }
})(typeof window !== 'undefined' ? window : this);
