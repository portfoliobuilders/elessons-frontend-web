/* ==========================================================================
   G-TEC eLessons — behaviour layer
   Vanilla, no dependencies. Every block is a self-contained init() that
   no-ops when its markup is absent, so both pages load the same file.
   ========================================================================== */
(function () {
  "use strict";

  var D = window.ELESSONS;
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };

  /* =======================================================================
     1. ANALYTICS  — deliverable: page views, CTA clicks, WA leads, purchases
     Pushes to GTM's dataLayer (the property already runs GTM) and mirrors to
     gtag if present. Add data-track="event_name" to any element to fire it.
     ===================================================================== */
  window.dataLayer = window.dataLayer || [];

  function track(event, params) {
    var payload = Object.assign({ event: event, ts: Date.now() }, params || {});
    window.dataLayer.push(payload);
    if (typeof window.gtag === "function") window.gtag("event", event, params || {});
    if (window.ELESSONS_DEBUG) console.log("[track]", event, params || {});
  }
  window.elTrack = track;

  document.addEventListener("click", function (e) {
    var el = e.target.closest("[data-track]");
    if (!el) return;
    var params = {};
    Object.keys(el.dataset).forEach(function (k) {
      if (k !== "track") params[k] = el.dataset[k];
    });
    track(el.dataset.track, params);
  });

  function initPageView() {
    track("page_view", {
      page_type: document.body.dataset.page || "other",
      course_id: document.body.dataset.courseId || undefined,
      grade: document.body.dataset.grade || undefined
    });
  }

  /* =======================================================================
     2. WHATSAPP  — deliverable #4
     Builds wa.me links with a pre-filled, context-aware message and reports
     each tap as a lead. Any <a data-wa> gets wired; context comes from
     data-wa-context or falls back to the page's course title.
     ===================================================================== */
  function waLink(context) {
    var msg = "Hi GTEC Team, I'm interested in " + context +
              ". Can you share more details?";
    return "https://wa.me/" + D.WA_NUMBER + "?text=" + encodeURIComponent(msg);
  }
  window.elWaLink = waLink;

  function initWhatsApp() {
    var pageCtx = document.body.dataset.waContext || "G-TEC eLessons classes";
    $$("[data-wa]").forEach(function (a) {
      var ctx = a.dataset.waContext || pageCtx;
      a.href = waLink(ctx);
      a.target = "_blank";
      a.rel = "noopener";
      a.addEventListener("click", function () {
        track("whatsapp_lead", {
          context: ctx,
          placement: a.dataset.waPlacement || "unknown",
          page_type: document.body.dataset.page || "other"
        });
      });
    });
  }

  /* =======================================================================
     3. LMS REDIRECT  — deliverable #5
     Sends an already-enrolled student to the LMS. Preserves the course they
     came from via ?next=, so the portal can deep-link after authentication,
     and carries utm_source so LMS logins are attributable.
     ===================================================================== */
  function lmsUrl(courseId) {
    var u = new URL(D.LMS_URL);
    if (courseId) u.searchParams.set("next", "/course/" + courseId);
    u.searchParams.set("utm_source", "website");
    u.searchParams.set("utm_medium", document.body.dataset.page || "site");
    return u.toString();
  }

  function initLms() {
    $$("[data-lms]").forEach(function (a) {
      var id = a.dataset.lms || document.body.dataset.courseId || "";
      a.href = lmsUrl(id);
      a.addEventListener("click", function () {
        track("lms_login_click", { course_id: id });
      });
    });
  }

  /* =======================================================================
     4. UTILITIES — currency, toast, cart
     ===================================================================== */
  var currency = localStorage.getItem("el_currency") || "INR";

  function money(inr) {
    var fx = D.FX[currency] || D.FX.INR;
    var val = Math.round(inr * fx.rate);
    return fx.sym + val.toLocaleString(currency === "INR" ? "en-IN" : "en-US");
  }
  window.elMoney = money;

  function initCurrency() {
    $$("[data-currency-select]").forEach(function (sel) {
      sel.value = currency;
      sel.addEventListener("change", function () {
        currency = sel.value;
        localStorage.setItem("el_currency", currency);
        track("currency_change", { currency: currency });
        location.reload();
      });
    });
  }

  var toastEl;
  function toast(msg) {
    if (!toastEl) {
      toastEl = document.createElement("div");
      toastEl.className = "toast";
      toastEl.setAttribute("role", "status");
      toastEl.setAttribute("aria-live", "polite");
      document.body.appendChild(toastEl);
    }
    toastEl.textContent = msg;
    toastEl.dataset.show = "true";
    clearTimeout(toastEl._t);
    toastEl._t = setTimeout(function () { toastEl.dataset.show = "false"; }, 2600);
  }

  var cart = JSON.parse(localStorage.getItem("el_cart") || "[]");
  function saveCart() {
    localStorage.setItem("el_cart", JSON.stringify(cart));
    $$("[data-cart-count]").forEach(function (n) {
      n.textContent = cart.length;
      n.hidden = cart.length === 0;
    });
    $$("[data-cart-total]").forEach(function (n) {
      n.textContent = money(cart.reduce(function (s, i) { return s + i.price; }, 0));
    });
  }
  function addToCart(item) {
    if (cart.some(function (i) { return i.id === item.id; })) { toast("Already in your cart"); return false; }
    cart.push(item); saveCart();
    track("add_to_cart", { item_id: item.id, item_name: item.name, value: item.price, currency: "INR" });
    toast(item.name + " added");
    return true;
  }
  function removeFromCart(id) {
    cart = cart.filter(function (i) { return i.id !== id; }); saveCart();
    track("remove_from_cart", { item_id: id });
  }
  window.elCart = { add: addToCart, remove: removeFromCart, items: function () { return cart; } };

  /* =======================================================================
     5. HEADER — mobile nav
     ===================================================================== */
  function initHeader() {
    var btn = $("[data-nav-toggle]"), nav = $("#site-nav");
    if (!btn || !nav) return;
    btn.addEventListener("click", function () {
      var open = nav.dataset.open === "true";
      nav.dataset.open = String(!open);
      btn.setAttribute("aria-expanded", String(!open));
    });
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A") { nav.dataset.open = "false"; btn.setAttribute("aria-expanded", "false"); }
    });
  }

  /* =======================================================================
     6. ACCORDIONS — one handler for FAQ, chapters and module groups
     ===================================================================== */
  function initAccordions() {
    document.addEventListener("click", function (e) {
      var btn = e.target.closest("[data-acc]");
      if (!btn) return;
      var panel = document.getElementById(btn.getAttribute("aria-controls"));
      if (!panel) return;
      var open = btn.getAttribute("aria-expanded") === "true";
      btn.setAttribute("aria-expanded", String(!open));
      panel.hidden = open;
      if (!open && btn.dataset.accTrack) track(btn.dataset.accTrack, { label: btn.dataset.accLabel || "" });
    });
  }

  /* =======================================================================
     7. TABLISTS — roving focus, Left/Right/Home/End per WAI-ARIA
     ===================================================================== */
  function initTablists() {
    $$('[role="tablist"]').forEach(function (list) {
      var tabs = $$('[role="tab"]', list);

      function select(tab) {
        tabs.forEach(function (t) {
          var on = t === tab;
          t.setAttribute("aria-selected", String(on));
          t.tabIndex = on ? 0 : -1;
          var p = document.getElementById(t.getAttribute("aria-controls"));
          if (p) p.hidden = !on;
        });
        if (tab.dataset.tabTrack) track(tab.dataset.tabTrack, { tab: tab.dataset.tabValue || tab.textContent.trim() });
        if (list.dataset.onSelect && typeof window[list.dataset.onSelect] === "function") {
          window[list.dataset.onSelect](tab.dataset.tabValue);
        }
      }
      list._select = select;

      tabs.forEach(function (tab, i) {
        tab.tabIndex = tab.getAttribute("aria-selected") === "true" ? 0 : -1;
        tab.addEventListener("click", function () { select(tab); });
        tab.addEventListener("keydown", function (e) {
          var n = null;
          if (e.key === "ArrowRight") n = tabs[(i + 1) % tabs.length];
          else if (e.key === "ArrowLeft") n = tabs[(i - 1 + tabs.length) % tabs.length];
          else if (e.key === "Home") n = tabs[0];
          else if (e.key === "End") n = tabs[tabs.length - 1];
          if (n) { e.preventDefault(); n.focus(); select(n); }
        });
      });
    });
  }

  /* =======================================================================
     8. HOME — multi-axis filtering
     ===================================================================== */
  function initHomeFilters() {
    var grid = $("#course-grid");
    if (!grid) return;

    var state = { grade: "all", subject: "all", mode: "all", type: "all", sort: "popular" };

    function render() {
      var items = D.catalogue.filter(function (c) {
        if (state.grade !== "all" && String(c.grade) !== state.grade) return false;
        if (state.subject !== "all" && c.subject !== state.subject) return false;
        if (state.type !== "all" && c.kind !== state.type) return false;
        if (state.mode === "live" && !c.live) return false;
        return true;
      });

      if (state.sort === "low") items = items.slice().sort(function (a, b) { return a.price - b.price; });
      if (state.sort === "high") items = items.slice().sort(function (a, b) { return b.price - a.price; });

      $("#result-count").innerHTML = "<b>" + items.length + "</b> " + (items.length === 1 ? "class" : "classes");

      if (!items.length) {
        grid.innerHTML = '<div class="empty-state" style="grid-column:1/-1">' +
          "<h3>No classes match those filters</h3>" +
          '<p class="small">Try clearing the subject or package filter.</p>' +
          '<button class="btn btn--ghost btn--sm" data-clear style="margin-top:16px">Clear all filters</button></div>';
        return;
      }

      grid.innerHTML = items.map(cardHTML).join("");
      track("catalogue_filter", Object.assign({ results: items.length }, state));
    }

    function cardHTML(c) {
      var bundle = c.kind === "bundle";
      var href = "course-detail.html?course=" + c.id;
      var modeBadges =
        '<span class="badge badge--live' + (bundle ? " badge--onDark" : "") + '">Live classes</span>' +
        '<span class="badge' + (bundle ? " badge--onDark" : "") + '">Recorded lessons</span>';

      return '<article class="ccard' + (bundle ? " ccard--bundle" : "") + '">' +
        '<div class="ccard__banner">' +
          (bundle ? '<span class="ccard__flag badge badge--gold">Best value</span>' : "") +
          '<div class="ccard__banner-fallback"' + (bundle ? ' style="background:linear-gradient(150deg,#143867,#081D3A)"' : "") + ">" +
            '<span class="sub"' + (bundle ? ' style="color:#fff"' : "") + ">" + (bundle ? "Grade " + c.grade : c.subject) + "</span>" +
            '<span class="eyebrow' + (bundle ? " eyebrow--light" : "") + '">' + (bundle ? "All subjects" : "Grade " + c.grade) + "</span>" +
          "</div></div>" +
        '<div class="ccard__body">' +
          '<p class="eyebrow' + (bundle ? " eyebrow--light" : "") + '">Grade ' + c.grade + " &middot; " + (bundle ? "Annual package" : "Single subject") + "</p>" +
          '<h3 class="ccard__title"><a href="' + href + '" data-track="course_card_click" data-course-id="' + c.id + '">' + (bundle ? "All Subjects" : c.subject) + "</a></h3>" +
          '<p class="tagline"' + (bundle ? ' style="color:rgba(255,255,255,.62)"' : "") + ">" + c.tagline + "</p>" +
          '<div class="ccard__badges">' + modeBadges + "</div>" +
          '<p class="ccard__desc">' + c.desc + "</p>" +
          '<div class="ccard__foot">' +
            (c.was ? '<p class="ccard__price-note">Separately <span class="ccard__strike">' + money(c.was) + "</span></p>" : "") +
            '<p class="ccard__price">' + money(c.price) + "</p>" +
            (c.was
              ? '<p class="ccard__save">Save ' + money(c.was - c.price) + " against buying separately</p>"
              : '<p class="ccard__price-note">This subject &middot; full academic year</p>') +
            '<div class="ccard__cta">' +
              '<a class="btn btn--sm ' + (bundle ? "btn--gold" : "btn--primary") + ' btn--block" href="' + href + '" data-track="cta_view_course" data-course-id="' + c.id + '">View course</a>' +
            "</div>" +
          "</div></div></article>";
    }

    $$("[data-filter]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var key = btn.dataset.filter, val = btn.dataset.value;
        state[key] = val;
        $$('[data-filter="' + key + '"]').forEach(function (b) {
          b.setAttribute("aria-pressed", String(b === btn));
        });
        render();
      });
    });

    var sortSel = $("#sort-select");
    if (sortSel) sortSel.addEventListener("change", function () { state.sort = sortSel.value; render(); });

    document.addEventListener("click", function (e) {
      if (!e.target.closest("[data-clear]")) return;
      state = { grade: "all", subject: "all", mode: "all", type: "all", sort: "popular" };
      $$("[data-filter]").forEach(function (b) {
        b.setAttribute("aria-pressed", String(b.dataset.value === "all"));
      });
      if (sortSel) sortSel.value = "popular";
      render();
    });

    render();
  }

  /* =======================================================================
     9. DETAIL — learning mode, buy tabs, syllabus, PDF
     ===================================================================== */
  function initDetail() {
    var box = $("#buybox");
    if (!box) return;

    var basePrice = Number(document.body.dataset.price || 12000);
    var courseId = document.body.dataset.courseId || "course";
    var courseName = document.body.dataset.courseName || "Course";
    var mode = "recorded";

    function currentPrice() { return mode === "live" ? basePrice + D.LIVE_UPLIFT : basePrice; }

    function paint() {
      var p = currentPrice();
      $$("[data-price-now]").forEach(function (n) { n.textContent = money(p); });
      $$("[data-price-was]").forEach(function (n) { n.textContent = money(Math.round(p * 1.5)); });
      $$("[data-price-save]").forEach(function (n) { n.textContent = "You save " + money(Math.round(p * 0.5)); });
      $$("[data-mode-label]").forEach(function (n) {
        n.textContent = mode === "live" ? "Live + Recorded plan" : "Recorded plan";
      });
    }

    $$("[data-mode]").forEach(function (opt) {
      function choose() {
        mode = opt.dataset.mode;
        $$("[data-mode]").forEach(function (o) { o.setAttribute("aria-checked", String(o === opt)); });
        paint();
        track("select_learning_mode", { mode: mode, course_id: courseId, value: currentPrice() });
      }
      opt.addEventListener("click", choose);
      opt.addEventListener("keydown", function (e) {
        if (e.key === " " || e.key === "Enter") { e.preventDefault(); choose(); }
      });
    });

    $$("[data-buy]").forEach(function (b) {
      b.addEventListener("click", function () {
        addToCart({ id: courseId + "-" + mode, name: courseName + " (" + mode + ")", price: currentPrice() });
        track("begin_checkout", { course_id: courseId, mode: mode, value: currentPrice(), currency: "INR" });
      });
    });

    /* Subject cards */
    var subjWrap = $("#subject-picker");
    if (subjWrap) {
      subjWrap.innerHTML = Object.keys(D.syllabus).map(function (s) {
        var n = D.countLive(s);
        var price = D.SUBJECT_PRICE[s];
        var free = price === 0;
        var chapters = D.syllabus[s].length;
        return '<div class="pick" data-subject="' + s + '">' +
          '<div class="pick__top"><div><p class="pick__name">' + s + "</p>" +
          '<p class="pick__meta">' + chapters + " chapters &middot; " + n + " lessons</p></div>" +
          (free ? '<span class="badge badge--free">Included free</span>' : "") + "</div>" +
          '<div class="pick__foot"><p class="pick__price">' + (free ? "Free" : money(price)) + "</p>" +
          (free
            ? '<span class="small">Bundled with any annual pack</span>'
            : '<button class="btn btn--ghost btn--sm" data-add-subject="' + s + '" data-price="' + price + '">Add subject</button>') +
          "</div></div>";
      }).join("");

      subjWrap.addEventListener("click", function (e) {
        var b = e.target.closest("[data-add-subject]");
        if (!b) return;
        var s = b.dataset.addSubject;
        if (addToCart({ id: courseId + "-sub-" + s, name: s, price: Number(b.dataset.price) })) {
          b.textContent = "Added"; b.classList.add("btn--added");
        }
      });
    }

    /* Module picker */
    var modWrap = $("#module-picker");
    if (modWrap) {
      modWrap.innerHTML = Object.keys(D.syllabus).map(function (s, si) {
        var chs = D.syllabus[s];
        var pid = "mod-panel-" + si;
        return '<div class="mod-group">' +
          '<button class="mod-group__btn" data-acc aria-expanded="' + (si === 0) + '" aria-controls="' + pid + '">' +
            '<span class="mod-group__sig">' + s.slice(0, 3).toUpperCase() + "</span>" +
            '<span><span class="mod-group__name">' + s + "</span><br>" +
            '<span class="mod-group__meta">' + chs.length + " modules &middot; " + money(D.MODULE_PRICE) + " each</span></span>" +
            '<svg class="mod-group__chev" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>' +
          "</button>" +
          '<div class="mod-group__panel" id="' + pid + '"' + (si === 0 ? "" : " hidden") + ">" +
            chs.map(function (c, ci) {
              var n = c.videos.filter(function (v) { return v.status === "live"; }).length;
              return '<div class="mod-row"><div><p class="mod-row__name">' + c.name + "</p>" +
                '<p class="mod-row__meta">' + n + " lessons &middot; " + money(D.MODULE_PRICE) + "</p></div>" +
                '<div class="mod-row__action"><button class="btn btn--ghost btn--sm" data-add-module="' + s + "|" + ci + '">+ Add</button></div></div>';
            }).join("") +
          "</div></div>";
      }).join("");

      modWrap.addEventListener("click", function (e) {
        var b = e.target.closest("[data-add-module]");
        if (!b) return;
        var parts = b.dataset.addModule.split("|");
        var ch = D.syllabus[parts[0]][Number(parts[1])];
        if (addToCart({ id: "mod-" + parts[0] + "-" + parts[1], name: ch.name, price: D.MODULE_PRICE })) {
          b.textContent = "\u2713 Added"; b.classList.add("btn--added");
        }
      });
    }

    /* Syllabus explorer */
    var sylWrap = $("#syllabus-panels");
    if (sylWrap) {
      sylWrap.innerHTML = Object.keys(D.syllabus).map(function (s, si) {
        var n = 0;
        var body = D.syllabus[s].map(function (c, ci) {
          var vids = c.videos.filter(function (v) { return v.status === "live"; });
          var pid = "ch-" + si + "-" + ci;
          var rows = vids.map(function (v) {
            n++;
            return '<div class="vid-row">' +
              '<span class="vid-row__no">' + String(n).padStart(3, "0") + "</span>" +
              '<span class="vid-row__name">' + v.t + "</span>" +
              '<span class="vid-row__dur">' + (v.d || "\u2014") + "</span>" +
              (v.free
                ? '<a class="vid-row__preview" href="#" data-track="preview_click" data-lesson="' + v.t.replace(/"/g, "") + '">Watch free</a>'
                : '<svg class="vid-row__lock" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-label="Included with purchase"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>') +
              "</div>";
          }).join("");
          return '<div class="syl-chapter">' +
            '<button class="syl-chapter__btn" data-acc aria-expanded="false" aria-controls="' + pid + '" data-acc-track="syllabus_chapter_open" data-acc-label="' + c.name + '">' +
              '<span class="syl-chapter__no">' + String(ci + 1).padStart(2, "0") + "</span>" +
              '<span class="syl-chapter__name">' + c.name + "</span>" +
              '<span class="syl-chapter__count">' + vids.length + " lessons</span>" +
              '<svg class="syl-chapter__chev" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>' +
            "</button>" +
            '<div class="syl-chapter__panel" id="' + pid + '" hidden role="region">' + rows + "</div></div>";
        }).join("");

        return '<div class="syl-panel" id="syl-' + si + '" role="tabpanel" tabindex="0" aria-label="' + s + ' syllabus"' + (si === 0 ? "" : " hidden") + ">" +
          body +
          '<div class="syl-foot"><p class="small">' + D.syllabus[s].length + " chapters &middot; " + D.countLive(s) + " lessons in " + s +
          '. Runtimes appear once each lesson is published.</p>' +
          '<a class="btn btn--ghost btn--sm" href="video-list.html" target="_blank" rel="noopener" data-track="download_video_list" data-subject="' + s + '">Download full list (PDF)</a></div></div>';
      }).join("");
    }

    paint();
  }

  /* =======================================================================
     10. BOOT
     ===================================================================== */
  document.addEventListener("DOMContentLoaded", function () {
    initHeader();
    initCurrency();
    initAccordions();
    initTablists();
    initHomeFilters();
    initDetail();
    initWhatsApp();
    initLms();
    saveCart();
    initPageView();
  });
})();
