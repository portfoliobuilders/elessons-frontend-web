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
    var preset = document.documentElement.getAttribute('data-currency');
    var fromUrl = null;
    try { fromUrl = new URLSearchParams(location.search).get('currency'); } catch (e2) {}
    var prefer = (fromUrl === 'aed' || fromUrl === 'inr') ? fromUrl
               : (preset === 'aed' || preset === 'inr') ? preset : null;
    if (prefer === 'aed') start = 'aed|AE';
    else if (prefer === 'inr') start = 'inr|IN';
    else if (GULF_TZ.indexOf(Intl.DateTimeFormat().resolvedOptions().timeZone) > -1) start = 'aed|AE';
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

/* ══════ lesson preview player (ported from indexnew.html) ══════ */
/* The frame is covered by .player-shield so the pointer never reaches it and
   the provider's own overlays never surface. Playback is hard-stopped twice:
   the player's own end bound and a polling guard. */
(function () {
  var root = document.getElementById('lesson-player');
  if (!root) return;

  var VID = root.dataset.vid;
  var CAP = parseFloat(root.dataset.cap) || 90;
  var q = function (s) { return root.querySelector(s); };
  var mount = q('#lesson-frame'), cover = q('.player-cover'), bar = q('.player-bar'),
      fill = q('.pfill'), tlabel = q('.ptime'), scrub = q('.pscrub'),
      shield = q('.player-shield'), bPlay = q('#p-toggle'), bMute = q('#p-mute'),
      iPlay = q('#i-play'), iPause = q('#i-pause'), iSound = q('#i-sound'), iMuted = q('#i-muted');

  var yt = null, timer = null, started = false, failed = false;

  function fmt(s) {
    s = Math.max(0, Math.floor(s || 0));
    return Math.floor(s / 60) + ':' + ('0' + (s % 60)).slice(-2);
  }
  function paint(t) {
    if (!fill || !tlabel || !scrub) return;
    var p = Math.max(0, Math.min(1, t / CAP));
    fill.style.width = (p * 100) + '%';
    tlabel.textContent = fmt(t) + ' / ' + fmt(CAP);
    scrub.setAttribute('aria-valuenow', Math.round(t));
    scrub.setAttribute('aria-valuetext', fmt(t) + ' of ' + fmt(CAP));
    scrub.setAttribute('aria-valuemax', Math.round(CAP));
  }
  function icons(playing) {
    if (!iPlay || !iPause || !bPlay) return;
    iPlay.style.display = playing ? 'none' : '';
    iPause.style.display = playing ? '' : 'none';
    bPlay.setAttribute('aria-label', playing ? 'Pause' : 'Play');
  }
  paint(0);

  function stopTimer() { if (timer) { clearInterval(timer); timer = null; } }
  function endNow() {
    stopTimer();
    try { yt && yt.pauseVideo(); } catch (e) {}
    paint(CAP);
    root.dataset.state = 'ended';
    if (typeof window.elTrack === 'function') {
      try { window.elTrack('preview_complete', window.__elPreviewCtx || {}); } catch (e) {}
    }
  }
  function watch() {
    stopTimer();
    timer = setInterval(function () {
      if (!yt || !yt.getCurrentTime) return;
      var t = yt.getCurrentTime();
      if (t >= CAP - 0.12) { endNow(); return; }
      paint(t);
    }, 200);
  }

  function fallback(msg) {
    if (failed || root.dataset.state === 'playing') return;
    failed = true;
    root.dataset.state = 'idle';
    var n = q('.player-note');
    if (n) n.textContent = msg || 'Preview could not load here. Browse the classes below.';
  }

  /* [ADDED] Missing ID shows the note instead of a broken embed. */
  if (!VID) {
    fallback('Preview video is not available yet.');
    /* still expose reset + controls below so a later ID can recover */
  }

  function loadAPI(done) {
    if (window.YT && window.YT.Player) return done();
    var prev = window.onYouTubeIframeAPIReady;
    window.onYouTubeIframeAPIReady = function () { if (prev) prev(); done(); };
    if (!document.getElementById('vp-api')) {
      var s = document.createElement('script');
      s.id = 'vp-api';
      s.src = 'https://www.youtube.com/iframe_api';
      s.onerror = function () { fallback('Preview could not load here. Browse the classes below.'); };
      document.head.appendChild(s);
    }
    setTimeout(function () {
      if (!(window.YT && window.YT.Player)) {
        fallback('Preview could not load here. Browse the classes below.');
      }
    }, 7000);
  }

  function ensureMount() {
    mount = q('#lesson-frame');
    if (mount && mount.tagName !== 'IFRAME') return mount;
    var stage = q('.player-stage');
    if (!stage) return null;
    if (mount) mount.parentNode.removeChild(mount);
    var div = document.createElement('div');
    div.id = 'lesson-frame';
    var shieldEl = q('.player-shield');
    if (shieldEl) stage.insertBefore(div, shieldEl);
    else stage.insertBefore(div, stage.firstChild);
    mount = div;
    return mount;
  }

  function build() {
    if (!ensureMount()) return;
    yt = new YT.Player(mount, {
      videoId: VID,
      host: 'https://www.youtube-nocookie.com',
      playerVars: {
        autoplay: 1, controls: 0, rel: 0, modestbranding: 1, iv_load_policy: 3,
        disablekb: 1, fs: 0, playsinline: 1, cc_load_policy: 0,
        end: Math.round(CAP), origin: window.location.origin
      },
      events: {
        onReady: function (e) {
          root.dataset.state = 'playing';
          if (bar) bar.hidden = false;
          icons(true);
          e.target.playVideo();
          watch();
        },
        onStateChange: function (e) {
          if (e.data === YT.PlayerState.PLAYING) { root.dataset.state = 'playing'; icons(true); watch(); }
          else if (e.data === YT.PlayerState.PAUSED) { root.dataset.state = 'paused'; icons(false); stopTimer(); }
          else if (e.data === YT.PlayerState.ENDED) { endNow(); }
        },
        onError: function () {
          stopTimer();
          fallback('This preview is unavailable right now. Browse the classes below.');
        }
      }
    });
  }

  function start() {
    VID = root.dataset.vid;
    CAP = parseFloat(root.dataset.cap) || 90;
    if (!VID) { fallback('Preview video is not available yet.'); return; }
    if (started) return;
    started = true;
    failed = false;
    root.dataset.state = 'loading';
    if (typeof window.elTrack === 'function') {
      try { window.elTrack('preview_play', window.__elPreviewCtx || {}); } catch (e) {}
    }
    loadAPI(build);
  }

  function toggle() {
    if (!started) return start();
    if (!yt) return;
    if (root.dataset.state === 'playing') yt.pauseVideo(); else yt.playVideo();
  }

  if (cover) cover.addEventListener('click', start);
  if (shield) shield.addEventListener('click', toggle);
  if (bPlay) bPlay.addEventListener('click', toggle);

  if (bMute) bMute.addEventListener('click', function () {
    if (!yt) return;
    var m = yt.isMuted();
    m ? yt.unMute() : yt.mute();
    if (iSound) iSound.style.display = m ? '' : 'none';
    if (iMuted) iMuted.style.display = m ? 'none' : '';
    bMute.setAttribute('aria-label', m ? 'Mute' : 'Unmute');
  });

  function seekFromX(clientX) {
    if (!yt || !yt.seekTo || !scrub) return;
    var r = scrub.getBoundingClientRect();
    var p = Math.max(0, Math.min(1, (clientX - r.left) / r.width));
    yt.seekTo(p * CAP, true);
    paint(p * CAP);
    if (root.dataset.state === 'ended') { root.dataset.state = 'playing'; yt.playVideo(); }
  }
  if (scrub) {
    scrub.addEventListener('click', function (e) { seekFromX(e.clientX); });
    scrub.addEventListener('keydown', function (e) {
      if (!yt || !yt.getCurrentTime) return;
      var t = yt.getCurrentTime(), step = e.shiftKey ? 10 : 5, n = null;
      if (e.key === 'ArrowRight') n = Math.min(CAP, t + step);
      if (e.key === 'ArrowLeft') n = Math.max(0, t - step);
      if (e.key === 'Home') n = 0;
      if (e.key === 'End') n = CAP - 1;
      if (n === null) return;
      e.preventDefault();
      yt.seekTo(n, true); paint(n);
    });
  }

  var replay = q('#p-replay');
  if (replay) replay.addEventListener('click', function () {
    if (!yt) return start();
    root.dataset.state = 'playing';
    yt.seekTo(0, true); yt.playVideo(); watch();
  });

  /* [ADDED] Re-point the player at another video without a full page reload. */
  window.gtecPlayerReset = function (vid, cap, title) {
    try {
      stopTimer();
      try { if (yt && yt.destroy) yt.destroy(); } catch (e) {}
      yt = null;
      started = false;
      failed = false;
      root.dataset.state = 'idle';
      root.dataset.vid = vid || '';
      root.dataset.cap = String(cap || 90);
      VID = root.dataset.vid;
      CAP = parseFloat(root.dataset.cap) || 90;
      ensureMount();
      paint(0);
      if (bar) bar.hidden = true;
      icons(false);
      var t = q('.player-title');
      if (t && title) t.textContent = title;
      var note = q('.player-note');
      if (note) note.textContent = 'A real teacher at a real board \u2014 the same way every chapter is taught.';
      if (!VID) fallback('Preview video is not available yet.');
    } catch (e) {}
  };

  /* stop the clock if the section scrolls away */
  if ('IntersectionObserver' in window) {
    new IntersectionObserver(function (es) {
      es.forEach(function (en) {
        if (!en.isIntersecting && yt && root.dataset.state === 'playing') {
          try { yt.pauseVideo(); } catch (e) {}
        }
      });
    }, { threshold: 0.15 }).observe(root);
  }
})();
