/**
 * Course filters + testimonial tabs (Phase 5–7)
 */
(function () {
  /* ── Course filters ─────────────────────────────────────────────── */
  var filterRoot = document.querySelector(".course-filters");
  var grid = document.getElementById("course-grid");
  var status = document.getElementById("filter-status");
  if (filterRoot && grid) {
    var buttons = filterRoot.querySelectorAll("[data-filter]");
    var cards = grid.querySelectorAll(".course-card");

    function announce(filter, count) {
      if (!status) return;
      status.textContent =
        filter === "All"
          ? count + " packages shown"
          : count + " packages for " + filter;
    }

    filterRoot.addEventListener("click", function (e) {
      var btn = e.target.closest("[data-filter]");
      if (!btn) return;
      var filter = btn.getAttribute("data-filter");
      buttons.forEach(function (b) {
        b.setAttribute("aria-pressed", b === btn ? "true" : "false");
      });
      var visible = 0;
      cards.forEach(function (card) {
        var tags = card.getAttribute("data-tags") || "";
        var show = filter === "All" || tags.indexOf(filter) !== -1;
        card.hidden = !show;
        if (show) visible += 1;
      });
      announce(filter, visible);
    });
  }

  /* ── Testimonial tabs ───────────────────────────────────────────── */
  var tablist = document.querySelector('[role="tablist"]');
  if (!tablist) return;
  var tabs = Array.prototype.slice.call(tablist.querySelectorAll('[role="tab"]'));

  function activate(tab) {
    tabs.forEach(function (t) {
      var selected = t === tab;
      t.setAttribute("aria-selected", selected ? "true" : "false");
      t.tabIndex = selected ? 0 : -1;
      var panel = document.getElementById(t.getAttribute("aria-controls"));
      if (panel) panel.hidden = !selected;
    });
    tab.focus();
  }

  tablist.addEventListener("click", function (e) {
    var tab = e.target.closest('[role="tab"]');
    if (tab) activate(tab);
  });

  tablist.addEventListener("keydown", function (e) {
    var i = tabs.indexOf(document.activeElement);
    if (i < 0) return;
    var next = i;
    if (e.key === "ArrowRight" || e.key === "ArrowDown") next = (i + 1) % tabs.length;
    else if (e.key === "ArrowLeft" || e.key === "ArrowUp") next = (i - 1 + tabs.length) % tabs.length;
    else if (e.key === "Home") next = 0;
    else if (e.key === "End") next = tabs.length - 1;
    else return;
    e.preventDefault();
    activate(tabs[next]);
  });
})();
