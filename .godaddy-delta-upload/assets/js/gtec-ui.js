/* ==========================================================================
   G-TEC eLessons — shared site behaviour
   Lifted VERBATIM from indexnew.html so any new page behaves identically:
   mobile drawer + measured --nav-h, location-based currency painting
   (INR / AED / USD via geo-pricing.js — no manual switcher), the
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

/* [SCOPED] run the original logic once per tablist instead of once per page.
   [RE-INIT] exposed as window.gtecInitTablist so a tablist whose buttons are
   re-rendered can be re-bound; without it, replacing innerHTML silently drops
   the click and arrow-key handlers. Each tab is stamped so re-running on
   untouched nodes cannot double-bind. */
function gtecInitTablist(LIST){
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
    if (t.dataset.tabBound === '1') return;
    t.dataset.tabBound = '1';
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
}
window.gtecInitTablist = gtecInitTablist;
document.querySelectorAll('[role="tablist"]').forEach(gtecInitTablist);

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

/* ── location-based currency (automatic only) ──────────────────────────────
   Lives in geo-pricing.js. Detects country via IP (timezone fallback), maps
   to INR / AED / USD, and paints every .price from its authored datasets.
   There is no manual currency picker. */
(function () {
  function boot() {
    if (window.ELessonsGeoPricing && typeof window.ELessonsGeoPricing.detectAndApply === 'function') {
      window.ELessonsGeoPricing.detectAndApply();
      return;
    }
    /* Soft fallback if geo-pricing.js failed to load — keep India as last resort
       so the page still paints something readable. */
    document.querySelectorAll('.price').forEach(function (el) {
      if (el.dataset.inr) el.textContent = el.dataset.inr;
    });
    document.documentElement.setAttribute('data-currency', 'inr');
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
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

/* ══════ lesson preview player — eLessons Drive demos (YouTube fallback) ══════ */
(function () {
  var root = document.getElementById('lesson-player');
  if (!root) return;

  var q = function (s) { return root.querySelector(s); };
  var cover = q('.player-cover'), bar = q('.player-bar'), shield = q('.player-shield');
  var started = false, failed = false, driveFrame = null, yt = null;

  function driveId() { return root.dataset.drive || ''; }
  function ytId() { return root.dataset.vid || ''; }

  function fallback(msg) {
    if (failed || root.dataset.state === 'playing') return;
    failed = true;
    root.dataset.state = 'idle';
    var n = q('.player-note');
    if (n) n.textContent = msg || 'Preview could not load here. Browse the classes below.';
  }

  function clearMount() {
    var stage = q('.player-stage');
    if (!stage) return null;
    if (driveFrame && driveFrame.parentNode) driveFrame.parentNode.removeChild(driveFrame);
    driveFrame = null;
    try { if (yt && yt.destroy) yt.destroy(); } catch (e) {}
    yt = null;
    var old = q('#lesson-frame');
    if (old) old.parentNode.removeChild(old);
    var div = document.createElement('div');
    div.id = 'lesson-frame';
    var shieldEl = q('.player-shield');
    if (shieldEl) stage.insertBefore(div, shieldEl);
    else stage.appendChild(div);
    return div;
  }

  function startDrive(id) {
    var stage = q('.player-stage');
    if (!stage) return;
    clearMount();
    var frame = document.createElement('iframe');
    frame.id = 'lesson-frame';
    frame.title = 'eLessons demo class';
    frame.allow = 'autoplay; encrypted-media; picture-in-picture';
    frame.allowFullscreen = true;
    frame.src = 'https://drive.google.com/file/d/' + encodeURIComponent(id) + '/preview';
    var shieldEl = q('.player-shield');
    if (shieldEl) {
      shieldEl.style.pointerEvents = 'none';
      shieldEl.style.opacity = '0';
      stage.insertBefore(frame, shieldEl);
    } else {
      stage.appendChild(frame);
    }
    driveFrame = frame;
    if (bar) bar.hidden = true;
    if (cover) cover.style.display = 'none';
    root.dataset.state = 'playing';
  }

  function start() {
    if (started && (driveFrame || yt)) return;
    var d = driveId(), v = ytId();
    if (!d && !v) { fallback('Preview video is not available yet.'); return; }
    started = true;
    failed = false;
    root.dataset.state = 'loading';
    if (typeof window.elTrack === 'function') {
      try { window.elTrack('preview_play', window.__elPreviewCtx || {}); } catch (e) {}
    }
    if (d) { startDrive(d); return; }
    var mount = clearMount();
    if (shield) { shield.style.pointerEvents = ''; shield.style.opacity = ''; }
    function build() {
      yt = new YT.Player(mount, {
        videoId: v,
        host: 'https://www.youtube-nocookie.com',
        playerVars: { autoplay: 1, controls: 1, rel: 0, modestbranding: 1, playsinline: 1, origin: window.location.origin },
        events: {
          onReady: function () { root.dataset.state = 'playing'; if (bar) bar.hidden = true; if (cover) cover.style.display = 'none'; },
          onError: function () { fallback('This preview is unavailable right now.'); }
        }
      });
    }
    if (window.YT && window.YT.Player) return build();
    var prev = window.onYouTubeIframeAPIReady;
    window.onYouTubeIframeAPIReady = function () { if (prev) prev(); build(); };
    if (!document.getElementById('vp-api')) {
      var s = document.createElement('script');
      s.id = 'vp-api';
      s.src = 'https://www.youtube.com/iframe_api';
      s.onerror = function () { fallback(); };
      document.head.appendChild(s);
    }
  }

  if (cover) cover.addEventListener('click', start);
  if (shield) shield.addEventListener('click', start);
  var playBtn = q('.play');
  if (playBtn) playBtn.addEventListener('click', function (e) { e.stopPropagation(); start(); });
  var replay = q('#p-replay');
  if (replay) replay.addEventListener('click', function () {
    started = false;
    if (cover) cover.style.display = '';
    root.dataset.state = 'idle';
    start();
  });

  window.gtecPlayerReset = function (id, cap, title) {
    try {
      started = false;
      failed = false;
      root.dataset.state = 'idle';
      /* Drive file ids are long; YouTube ids are 11 chars */
      if (id && String(id).length > 15) {
        root.dataset.drive = id;
        root.dataset.vid = '';
      } else {
        root.dataset.vid = id || '';
        root.dataset.drive = root.dataset.drive || '';
        if (!id) root.dataset.drive = '';
      }
      root.dataset.cap = String(cap || 90);
      clearMount();
      if (shield) { shield.style.pointerEvents = ''; shield.style.opacity = ''; }
      if (cover) cover.style.display = '';
      if (bar) bar.hidden = true;
      var t = q('.player-title');
      if (t && title) t.textContent = title;
      var note = q('.player-note');
      if (note) note.textContent = 'A real eLessons teacher at the board \u2014 the same way every chapter is taught.';
      if (!driveId() && !ytId()) fallback('Preview video is not available yet.');
    } catch (e) {}
  };
})();
