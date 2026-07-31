/**
 * Site config for marketing CTAs (Phase 6–7)
 * Full Razorpay checkout lives in the Flutter app — marketing Buy now
 * opens WhatsApp with a pre-filled package enquiry.
 */
window.ELessons = window.ELessons || {
  whatsapp: "971568056001",
  email: "contact@elessons.net",
  buyUrl: function (grade, stream) {
    var text =
      "Hi G-TEC eLessons, I want to buy the Grade " +
      grade +
      " " +
      stream +
      " annual package (AED 1200).";
    return "https://wa.me/" + this.whatsapp + "?text=" + encodeURIComponent(text);
  },
};
