<!DOCTYPE html>
<html lang="en" data-color-scheme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home</title>
  <meta name="description" content="CBSE / NCERT video lessons and notes for grades 8 to 12. A real teacher at a real board. AED 1200 for the full academic year.">

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

  <script src="/js/nav.js" defer></script>
  <script src="/js/interactive.js" defer></script>
</body>
</html>
