/* ==========================================================================
   G-TEC eLessons — location-based pricing (automatic only)
   Detects the shopper's country via IP geolocation, maps it to a price tier,
   and paints every .price element from its authored data-* attributes.
   Nothing is FX-converted at runtime — each tier is an independent authored list.

   There is NO manual currency switcher. Price tier is always derived from
   country (IP), with timezone as a short provisional guess while geo loads.

   Supported country → tier:
     IN                         → INR
     AE                         → AED (UAE)
     OM                         → OMR
     BH                         → BHD
     QA                         → QAR
     SA                         → SAR
     KW                         → KWD
     YE                         → AED (fallback; no dedicated sheet)
     everything else / unknown  → USD
   ========================================================================== */
(function (global) {
  'use strict';

  var LEGACY_STORAGE_KEY = 'el-currency';

  /* ISO country → currency key used in data-* / PRICING. */
  var COUNTRY_CURRENCY = {
    IN: 'inr',
    AE: 'aed',
    OM: 'omr',
    BH: 'bhd',
    QA: 'qar',
    SA: 'sar',
    KW: 'kwd',
    YE: 'aed'
  };

  var TZ_CURRENCY = {
    'Asia/Kolkata': 'inr',
    'Asia/Calcutta': 'inr',
    'Asia/Dubai': 'aed',
    'Asia/Muscat': 'omr',
    'Asia/Bahrain': 'bhd',
    'Asia/Qatar': 'qar',
    'Asia/Riyadh': 'sar',
    'Asia/Kuwait': 'kwd',
    'Asia/Aden': 'aed'
  };

  var NOTES = {
    inr: 'India pricing, charged in Indian rupees at checkout.',
    aed: 'UAE pricing, charged in AED at checkout.',
    omr: 'Oman pricing, charged in Omani rials at checkout.',
    bhd: 'Bahrain pricing, charged in Bahraini dinars at checkout.',
    qar: 'Qatar pricing, charged in Qatari riyals at checkout.',
    sar: 'Saudi pricing, charged in Saudi riyals at checkout.',
    kwd: 'Kuwait pricing, charged in Kuwaiti dinars at checkout.',
    usd: 'International pricing, charged in USD at checkout.'
  };

  var MARKET_LABELS = {
    inr: 'India · ₹ INR',
    aed: 'UAE · AED',
    omr: 'Oman · OMR',
    bhd: 'Bahrain · BHD',
    qar: 'Qatar · QAR',
    sar: 'Saudi Arabia · SAR',
    kwd: 'Kuwait · KWD',
    usd: 'International · $ USD'
  };

  function defaultCountry(cur) {
    if (cur === 'aed') return 'AE';
    if (cur === 'omr') return 'OM';
    if (cur === 'bhd') return 'BH';
    if (cur === 'qar') return 'QA';
    if (cur === 'sar') return 'SA';
    if (cur === 'kwd') return 'KW';
    if (cur === 'usd') return 'US';
    return 'IN';
  }

  function valueFor(cur, country) {
    return cur + '|' + (country || defaultCountry(cur));
  }

  function tierFromCountry(cc) {
    if (!cc) return null;
    var code = String(cc).toUpperCase();
    var cur = COUNTRY_CURRENCY[code];
    if (cur) return valueFor(cur, code);
    return valueFor('usd', code);
  }

  function tierFromTimezone() {
    try {
      var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
      var cur = TZ_CURRENCY[tz];
      if (cur) return valueFor(cur, defaultCountry(cur));
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

  function marketLabel(cur) {
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
      el.textContent = marketLabel(cur);
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
    COUNTRY_CURRENCY: COUNTRY_CURRENCY,
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
