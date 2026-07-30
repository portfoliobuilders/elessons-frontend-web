/* ==========================================================================
   G-TEC eLessons — shared site behaviour
   Lifted VERBATIM from indexnew.html so any new page behaves identically:
   mobile drawer + measured --nav-h, the INR/AED currency switcher, the
   scroll-reveal (.rv -> .in) and the accessible tab pattern.

   ONE deliberate change, marked [SCOPED] below: the original selected every
   .tab on the page as a single roving tablist. A detail page needs two
   independent tab groups, so the same logic now runs once per [role=tablist].
   ========================================================================== */



/* ══════════════ filters / tabs / scroll-reveal ══════════════ */

//document.getElementById('announce-x').onclick=function(){document.getElementById('announce').remove()};

document.querySelectorAll('.filter').forEach(function(f){
  f.onclick=function(){
    // no 'All' chip any more: clicking the active filter again clears it
    var wasOn = f.getAttribute('aria-pressed')==='true';
    document.querySelectorAll('.filter').forEach(function(o){o.setAttribute('aria-pressed','false')});
    if(!wasOn) f.setAttribute('aria-pressed','true');
    var key = wasOn ? null : f.textContent.trim();
    document.querySelectorAll('#course-grid .course').forEach(function(c){
      var show = !key || (c.dataset.tags||'').split('|').indexOf(key)>-1;
      c.style.display = show ? '' : 'none';
    });
  };
});

/* [SCOPED] run the original logic once per tablist instead of once per page */
document.querySelectorAll('[role="tablist"]').forEach(function(LIST){
  var tabs = [].slice.call(LIST.querySelectorAll('.tab'));
  if (!tabs.length) return;

  // stamp each panel with its card count so partial rows can centre themselves
  document.querySelectorAll('#panels > .grid').forEach(function(p){
    p.dataset.count = p.children.length;
  });

  function select(i, focus){
    tabs.forEach(function(o, k){
      var on = k === i, panel = document.getElementById(o.dataset.panel);
      o.setAttribute('aria-selected', on ? 'true' : 'false');
      o.tabIndex = on ? 0 : -1;
      if (panel) panel.hidden = !on;
    });
    if (focus) tabs[i].focus();
  }

  tabs.forEach(function(t, i){
    var pid = t.dataset.panel, panel = document.getElementById(pid);
    t.id = 'tab-' + pid;
    t.setAttribute('aria-controls', pid);
    t.tabIndex = t.getAttribute('aria-selected') === 'true' ? 0 : -1;
    if (panel) panel.setAttribute('aria-labelledby', t.id);

    t.addEventListener('click', function(){ select(i); });
    t.addEventListener('keydown', function(e){
      var d = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
      if (e.key === 'Home')      { e.preventDefault(); return select(0, true); }
      if (e.key === 'End')       { e.preventDefault(); return select(tabs.length - 1, true); }
      if (!d) return;
      e.preventDefault();
      select((i + d + tabs.length) % tabs.length, true);
    });
  });
});

/* [HARDENED] Originally this called window.matchMedia(...) and constructed an
   IntersectionObserver unguarded. If either API is missing the throw killed
   every script below it — the currency switcher and the mobile drawer — AND
   left all .rv elements at opacity:0, i.e. a blank page. The guard below fails
   in the safe direction: no observer means show everything immediately. */
(function () {
  var reveal = document.querySelectorAll('.rv');
  var animate = true;
  try { animate = window.matchMedia('(prefers-reduced-motion: no-preference)').matches; }
  catch (e) { animate = false; }

  if (animate && typeof IntersectionObserver === 'function') {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { threshold: .12 });
    reveal.forEach(function (el, i) { el.style.transitionDelay = (i % 4 * 90) + 'ms'; io.observe(el); });
  } else {
    reveal.forEach(function (el) { el.classList.add('in'); });
  }
})();


/* ══════════════ currency ══════════════ */

/* ── country / currency switcher ───────────────────────────────────────────
   Prices come from the two lists in the fee schedule (PAN INDIA in INR,
   GCC in AED). Nothing is converted at runtime — each price element carries
   both authored figures, so the two lists stay independent. */
(function(){
  var GULF_TZ = ['Asia/Dubai','Asia/Bahrain','Asia/Riyadh','Asia/Qatar',
                 'Asia/Kuwait','Asia/Muscat','Asia/Aden'];
  var pickers = document.querySelectorAll('.cur-select');

  function render(cur){
    document.querySelectorAll('.price').forEach(function(el){
      var v = el.dataset[cur];
      if (v) el.textContent = v;
    });
    document.querySelectorAll('.price-note').forEach(function(n){
      n.textContent = cur === 'aed'
        ? 'Gulf pricing, charged in AED at checkout.'
        : 'India pricing, charged in Indian rupees at checkout.';
    });
    document.documentElement.setAttribute('data-currency', cur);
  }

  function sync(value){
    var cur = value.split('|')[0];
    pickers.forEach(function(sel){
      var i, exact = -1, firstOfCur = -1;
      for (i = 0; i < sel.options.length; i++){
        if (sel.options[i].value === value) exact = i;
        if (firstOfCur < 0 && sel.options[i].value.split('|')[0] === cur) firstOfCur = i;
      }
      // the nav picker lists currencies, the pricing picker lists countries, so
      // fall back to the first option of the right currency when there is no exact match
      sel.selectedIndex = exact > -1 ? exact : firstOfCur;
    });
    render(cur);
  }

  pickers.forEach(function(sel){
    sel.addEventListener('change', function(){ sync(sel.value); });
  });

  var start = 'inr|IN';
  try {
    if (GULF_TZ.indexOf(Intl.DateTimeFormat().resolvedOptions().timeZone) > -1) start = 'aed|AE';
  } catch (e) {}
  sync(start);
})();



/* ══════════════ nav drawer ══════════════ */

/* ── in-page navigation: measured sticky offset, smooth scroll, mobile drawer ── */
(function () {
  var header = document.getElementById('sitenav');
  var burger = document.getElementById('burger');
  var drawer = document.getElementById('mnav');
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)');

  function navH() { return header ? Math.round(header.getBoundingClientRect().height) : 68; }

  function syncVars() {
    document.documentElement.style.setProperty('--nav-h', navH() + 'px');
    if (drawer && drawer.dataset.open === 'true') {
      drawer.style.setProperty('--mnav-top',
        Math.round(header.getBoundingClientRect().bottom) + 'px');
    }
  }
  syncVars();
  window.addEventListener('resize', function () {
    syncVars();
    if (window.innerWidth >= 1000) closeMenu();   // never strand a locked body
  });
  window.addEventListener('load', syncVars);
  if (window.ResizeObserver && header) new ResizeObserver(syncVars).observe(header);

  function closeMenu() {
    if (!drawer || drawer.dataset.open !== 'true') return;
    drawer.dataset.open = 'false';
    burger.setAttribute('aria-expanded', 'false');
    burger.setAttribute('aria-label', 'Open menu');
    document.body.style.overflow = '';
  }
  function openMenu() {
    if (!drawer) return;
    drawer.style.setProperty('--mnav-top',
      Math.round(header.getBoundingClientRect().bottom) + 'px');
    drawer.dataset.open = 'true';
    burger.setAttribute('aria-expanded', 'true');
    burger.setAttribute('aria-label', 'Close menu');
    document.body.style.overflow = 'hidden';
  }
  if (burger) {
    burger.addEventListener('click', function () {
      drawer.dataset.open === 'true' ? closeMenu() : openMenu();
    });
  }
  if (drawer) {
    drawer.addEventListener('click', function (e) {
      if (e.target === drawer) closeMenu();          // backdrop
    });
  }
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') { closeMenu(); if (burger) burger.focus(); }
  });

  function scrollToEl(el) {
    var y = el.id === 'top'
      ? 0
      : el.getBoundingClientRect().top + window.pageYOffset - navH() - 14;
    window.scrollTo({ top: Math.max(0, y), behavior: reduce.matches ? 'auto' : 'smooth' });
  }

  /* every in-page link — nav, drawer, Buy now, footer, hero CTAs — routes through here,
     so nothing navigates away and nothing lands under the sticky header */
  document.addEventListener('click', function (e) {
    var a = e.target.closest ? e.target.closest('a[href^="#"]') : null;
    if (!a || a.hasAttribute('download') || a.target === '_blank') return;
    var href = a.getAttribute('href');
    if (!href || href.length < 2) return;
    var el = document.getElementById(decodeURIComponent(href.slice(1)));
    if (!el) return;
    e.preventDefault();
    closeMenu();
    scrollToEl(el);
    history.replaceState(null, '', href);
    if (!el.hasAttribute('tabindex')) el.setAttribute('tabindex', '-1');
    el.focus({ preventScroll: true });
  });

  /* deep link on load lands below the header too */
  window.addEventListener('load', function () {
    if (!location.hash || location.hash.length < 2) return;
    var el = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (el) setTimeout(function () { scrollToEl(el); }, 60);
  });
})();
