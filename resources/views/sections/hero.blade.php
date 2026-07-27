{{-- G-TEC eLessons — Hero section
     Expects asset base: /images/hero/ (public/)
--}}
<section class="hero hero--lattice" aria-labelledby="hero-heading">
  <div class="hero__grid">
    <div class="hero__copy">
      <p class="hero__brand hero__reveal" aria-hidden="true">
        G-TEC <span>eLessons</span>
      </p>

      <p class="hero__eyebrow hero__reveal hero__reveal--delay">
        <span class="hero__eyebrow-dot" aria-hidden="true"></span>
        <span>CBSE / NCERT · Grades 8–12</span>
      </p>

      <h1 id="hero-heading" class="hero__title hero__reveal hero__reveal--delay">
        Traditional chalk-board class from
        <span class="hero__title-accent">the comfort of your home</span>
      </h1>

      <p class="hero__lead hero__reveal hero__reveal--delay-2">
        No animation. No graphics. A real teacher at a real board, filmed and delivered
        to the device your child already owns — with notes for every chapter.
      </p>

      <div class="hero__actions hero__reveal hero__reveal--delay-2">
        <a href="#courses" class="btn btn--primary">
          Buy the annual package
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
        </a>
        <a href="#demo" class="btn btn--ghost">Watch a free class</a>
      </div>

      <p class="hero__proof hero__reveal hero__reveal--delay-2">
        <span><strong>AED 1,200</strong> / full year</span>
        <span aria-hidden="true">·</span>
        <span>All subjects included</span>
        <span aria-hidden="true">·</span>
        <span>UAE · India · Bahrain · KSA</span>
      </p>
    </div>

    <div class="hero__model-stage">
      <div class="hero__model-halo" aria-hidden="true"></div>
      <picture>
        <source
          type="image/webp"
          srcset="
            /images/hero/model-suit-320w.webp 320w,
            /images/hero/model-suit-640w.webp 640w,
            /images/hero/model-suit-960w.webp 960w
          "
          sizes="(min-width: 1000px) 470px, (min-width: 640px) 420px, 90vw"
        >
        <img
          class="hero__model"
          src="/images/hero/model-suit-fallback.jpg"
          srcset="
            /images/hero/model-suit-320w.jpg 320w,
            /images/hero/model-suit-640w.jpg 640w,
            /images/hero/model-suit-960w.jpg 960w
          "
          sizes="(min-width: 1000px) 470px, (min-width: 640px) 420px, 90vw"
          alt="G-TEC instructor in a light blue suit"
          width="967"
          height="1000"
          fetchpriority="high"
          loading="eager"
          decoding="async"
        >
      </picture>
    </div>
  </div>
</section>
