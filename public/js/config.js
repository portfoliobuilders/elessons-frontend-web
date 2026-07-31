/**
 * Site config for marketing CTAs.
 * Full card/Razorpay checkout lives in the Flutter app / future payment route.
 * Marketing Buy now + brochure checkout open WhatsApp with a pre-filled enquiry.
 * AED shoppers reach the Gulf line; INR shoppers reach India admissions.
 */
window.ELessons = window.ELessons || {
  whatsappInr: "919745553944",
  whatsappAed: "971568056001",
  whatsapp: "971568056001",
  email: "contact@elessons.net",
  whatsappFor: function (currency) {
    var c = currency || (document.documentElement.getAttribute("data-currency") || "aed");
    return c === "inr" ? this.whatsappInr : this.whatsappAed;
  },
  buyUrl: function (grade, stream, currency) {
    var cur = currency || "aed";
    var text =
      "Hi G-TEC eLessons, I want to buy the Grade " +
      grade +
      " " +
      stream +
      " annual package" +
      (cur === "inr" ? " (INR)." : " (AED).");
    return "https://wa.me/" + this.whatsappFor(cur) + "?text=" + encodeURIComponent(text);
  },
};
