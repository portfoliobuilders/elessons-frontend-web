<!DOCTYPE html>
<html lang="en" data-color-scheme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home</title>

  @include('components.head-seo')

  {{-- Phase 4: self-hosted fonts (no Google Fonts CDN on critical path) --}}
  <link rel="preload" href="/fonts/plus-jakarta-sans-800.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/fonts/plus-jakarta-sans-400.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/images/hero/model-suit-640w.webp" as="image" type="image/webp" imagesrcset="/images/hero/model-suit-320w.webp 320w, /images/hero/model-suit-640w.webp 640w, /images/hero/model-suit-960w.webp 960w" imagesizes="(min-width: 1000px) 470px, 90vw">

  <link rel="stylesheet" href="/css/app.css">
</head>
<body>
  @include('components.header-nav')

  <main id="main" tabindex="-1">
    @include('sections.hero')
    @include('sections.how-it-works')
    @include('sections.demo')
    @include('sections.courses')
    @include('sections.board')
    @include('sections.why')
    @include('sections.teachers')
    @include('sections.testimonials')
    @include('sections.faq')
    @include('sections.cta-band')
    @include('sections.contact')
  </main>

  @include('components.footer')

  <div class="mobile-enroll" role="region" aria-label="Quick enrol">
    <a href="#courses" class="btn btn--navy btn--sm">View packages</a>
    <a
      href="https://wa.me/971568056001?text=Hi%20G-TEC%20eLessons%2C%20I%20want%20to%20enrol%20for%20the%20annual%20package%20(AED%201200)."
      class="btn btn--primary btn--sm"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Enrol on WhatsApp"
    >Enrol on WhatsApp</a>
  </div>

  <a
    class="wa-float"
    href="https://wa.me/971568056001?text=Hi%20G-TEC%20eLessons%2C%20I%27d%20like%20to%20know%20more%20about%20your%20courses."
    target="_blank"
    rel="noopener noreferrer"
    aria-label="Chat on WhatsApp"
    title="Chat on WhatsApp"
  >
    <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12.04 2C6.6 2 2.18 6.42 2.18 11.86c0 1.94.53 3.76 1.45 5.32L2 22l4.96-1.58a9.8 9.8 0 0 0 5.08 1.4c5.43 0 9.85-4.42 9.85-9.86S17.47 2 12.04 2Zm5.77 14c-.24.68-1.4 1.3-1.93 1.34-.5.05-1.13.07-1.82-.11a15.6 15.6 0 0 1-1.65-.62c-2.9-1.26-4.8-4.2-4.94-4.4-.15-.2-1.19-1.58-1.19-3.02 0-1.44.75-2.14 1.02-2.44.27-.29.59-.36.78-.36h.56c.18 0 .42-.07.66.5.24.59.83 2.03.9 2.18.07.15.12.32.02.51-.1.2-.15.32-.3.49-.14.17-.3.38-.44.51-.14.15-.29.3-.13.6.17.29.75 1.23 1.6 2 1.11.98 2.04 1.29 2.33 1.44.29.15.46.12.63-.07.17-.2.73-.85.92-1.14.2-.29.39-.24.66-.15.27.1 1.7.8 2 .95.29.15.48.22.55.34.07.13.07.73-.17 1.42Z"/></svg>
  </a>

  <script src="/js/config.js" defer></script>
  <script src="/js/nav.js" defer></script>
  <script src="/js/interactive.js" defer></script>
  <script src="/js/form.js" defer></script>
</body>
</html>
