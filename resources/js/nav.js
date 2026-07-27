/**
 * Mobile nav toggle — progressive enhancement only.
 * Desktop nav works without this script.
 */
(function () {
  var toggle = document.getElementById("nav-toggle");
  var panel = document.getElementById("nav-panel");
  if (!toggle || !panel) return;

  function setOpen(open) {
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    toggle.querySelector(".sr-only").textContent = open
      ? "Close navigation menu"
      : "Open navigation menu";
    if (open) {
      panel.hidden = false;
      panel.classList.add("is-open");
    } else {
      panel.classList.remove("is-open");
      panel.hidden = true;
    }
  }

  toggle.addEventListener("click", function () {
    var open = toggle.getAttribute("aria-expanded") !== "true";
    setOpen(open);
  });

  panel.addEventListener("click", function (e) {
    if (e.target.closest("a")) setOpen(false);
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && toggle.getAttribute("aria-expanded") === "true") {
      setOpen(false);
      toggle.focus();
    }
  });
})();
