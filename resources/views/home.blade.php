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

  <script src="/js/config.js" defer></script>
  <script src="/js/nav.js" defer></script>
  <script src="/js/interactive.js" defer></script>
  <script src="/js/form.js" defer></script>
</body>
</html>
