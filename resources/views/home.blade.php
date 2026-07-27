<!DOCTYPE html>
<html lang="en" data-color-scheme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home</title>
  <meta name="description" content="CBSE / NCERT video lessons and notes for grades 8 to 12. A real teacher at a real board. AED 1200 for the full academic year.">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&family=JetBrains+Mono:wght@500;600&family=Instrument+Serif:ital@0;1&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="/css/app.css">
</head>
<body>
  @include('components.header-nav')

  <main id="main" tabindex="-1">
    @include('sections.hero')

    <section id="how" class="sec wrap" aria-labelledby="how-heading" hidden>
      <h2 id="how-heading" class="h2">How it works</h2>
    </section>

    <section id="demo" class="sec wrap" aria-labelledby="demo-heading" hidden>
      <h2 id="demo-heading" class="h2">Watch a free class</h2>
    </section>

    <section id="courses" class="sec wrap" aria-labelledby="courses-heading" hidden>
      <h2 id="courses-heading" class="h2">Courses</h2>
    </section>

    @include('sections.faq')

    <section id="contact" class="sec" aria-labelledby="contact-heading">
      <div class="wrap" style="max-width: 560px">
        <h2 id="contact-heading" class="h2">Get in touch</h2>
        <p class="body text-secondary" style="margin-top: var(--space-md)">
          Tell us your child’s grade and we will point you to the right package.
        </p>

        <form class="mt" style="margin-top: var(--space-xl); display: grid; gap: var(--space-lg)" action="#" method="post" novalidate>
          <div class="field">
            <label class="field__required" for="f-n">Parent or student name</label>
            <input id="f-n" name="name" type="text" autocomplete="name" required aria-required="true">
          </div>

          <div class="field">
            <label class="field__required" for="f-e">Email address</label>
            <input id="f-e" name="email" type="email" autocomplete="email" required aria-required="true" aria-describedby="email-hint">
            <span id="email-hint" class="field__hint">We’ll never share your email.</span>
          </div>

          <div class="field">
            <label for="f-msg">Message</label>
            <textarea id="f-msg" name="message" rows="4" aria-describedby="msg-hint"></textarea>
            <span id="msg-hint" class="field__hint">Optional — grade, board, or questions.</span>
          </div>

          <button type="submit" class="btn btn--primary" style="justify-self: start">
            Send message
          </button>
        </form>
      </div>
    </section>
  </main>

  @include('components.footer')

  <script src="/js/nav.js" defer></script>
</body>
</html>
