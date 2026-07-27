{{-- Primary site header — keyboard + screen-reader friendly --}}
<a href="#main" class="skip-link">Skip to main content</a>

<header class="site-header">
  <div class="site-header__inner">
    <a href="/" class="site-header__logo" aria-label="G-TEC eLessons home">
      G-TEC <span>eLessons</span>
    </a>

    <nav class="site-nav" aria-label="Primary navigation">
      <button
        type="button"
        class="site-nav__toggle"
        id="nav-toggle"
        aria-expanded="false"
        aria-controls="nav-panel"
      >
        <span class="sr-only">Open navigation menu</span>
        <span class="site-nav__toggle-bars" aria-hidden="true"></span>
      </button>

      <ul class="site-nav__list" role="list">
        <li>
          <a href="/" class="site-nav__link" aria-current="page">Home</a>
        </li>
        <li>
          <a href="#courses" class="site-nav__link">Courses</a>
        </li>
        <li>
          <a href="#how" class="site-nav__link">How it works</a>
        </li>
        <li>
          <a href="#faq" class="site-nav__link">FAQ</a>
        </li>
        <li>
          <a href="#contact" class="site-nav__link site-nav__cta">Get in touch</a>
        </li>
      </ul>
    </nav>
  </div>

  <div class="site-nav__panel" id="nav-panel" hidden>
    <ul class="site-nav__list" role="list">
      <li>
        <a href="/" class="site-nav__link" aria-current="page">Home</a>
      </li>
      <li>
        <a href="#courses" class="site-nav__link">Courses</a>
      </li>
      <li>
        <a href="#how" class="site-nav__link">How it works</a>
      </li>
      <li>
        <a href="#faq" class="site-nav__link">FAQ</a>
      </li>
      <li>
        <a href="#contact" class="site-nav__link site-nav__cta">Get in touch</a>
      </li>
    </ul>
  </div>
</header>
