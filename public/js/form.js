/**
 * Static contact form → mailto fallback (no backend required)
 */
(function () {
  var form = document.querySelector("#contact-form, #contact form, form.contact-form");
  if (!form) return;

  var status = document.getElementById("form-status");
  if (!status) {
    status = document.createElement("p");
    status.id = "form-status";
    status.className = "form-status";
    status.setAttribute("role", "status");
    status.setAttribute("aria-live", "polite");
    form.appendChild(status);
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var name = (form.querySelector("#f-n") || {}).value || "";
    var email = (form.querySelector("#f-e") || {}).value || "";
    var mobile = (form.querySelector("#f-m") || {}).value || "";
    var message = (form.querySelector("#f-msg") || {}).value || "";

    if (!name.trim() || !email.trim()) {
      status.hidden = false; status.className = "form-status form-status--err is-visible";
      status.textContent = "Please enter your name and email.";
      return;
    }

    var body = [
      "Name: " + name.trim(),
      "Email: " + email.trim(),
      mobile.trim() ? "Mobile: " + mobile.trim() : "",
      "",
      message.trim() || "(No message)",
    ]
      .filter(Boolean)
      .join("\n");

    var mailto =
      "mailto:contact@elessons.net" +
      "?subject=" +
      encodeURIComponent("eLessons enquiry from " + name.trim()) +
      "&body=" +
      encodeURIComponent(body);

    status.hidden = false; status.className = "form-status form-status--ok is-visible";
    status.textContent = "Opening your email app to send the message…";
    window.location.href = mailto;
  });
})();
