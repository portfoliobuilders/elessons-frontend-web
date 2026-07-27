<!DOCTYPE html>
<html lang="en" data-color-scheme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home</title>
  <meta name="description" content="CBSE / NCERT video lessons and notes for grades 8 to 12. A real teacher at a real board. AED 1200 for the full academic year.">

  {{-- Phase 4 will self-host fonts; Phase 2 uses preconnect + display=swap --}}
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&family=JetBrains+Mono:wght@500;600&family=Instrument+Serif:ital@0;1&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="/css/app.css">
</head>
<body>
  <a href="#main" class="skip-link">Skip to main content</a>

  <main id="main">
    @include('sections.hero')

    {{-- Placeholders for later phases --}}
    <section id="demo" class="sec wrap" hidden aria-hidden="true"></section>
    <section id="courses" class="sec wrap" hidden aria-hidden="true"></section>
  </main>
</body>
</html>
