<section id="contact" class="sec" aria-labelledby="contact-heading">
  <div class="wrap contact-grid">
    <div>
      <p class="section-eyebrow">Contact</p>
      <h2 id="contact-heading" class="h2" style="margin-top: var(--space-sm)">Get in touch.</h2>

      <div class="contact-card">
        <p class="contact-card__label">Corporate office</p>
        <p>eLessons.Net, #104, Level 5, Infantry Techno Park,<br>Infantry Road, Bangalore 560001, Karnataka, India</p>
        <a href="mailto:contact@elessons.net">contact@elessons.net</a>
      </div>

      <div class="contact-card">
        <p class="contact-card__label">Middle East office</p>
        <p>Staffin Consultancy FZE, Sharjah Research Technology<br>&amp; Innovation Park, Sharjah, UAE</p>
        <a href="https://wa.me/971568056001" rel="noopener noreferrer" target="_blank">+971 568056001</a>
      </div>
    </div>

    <form class="contact-form" action="#" method="post">
      <div class="field">
        <label class="field__required" for="f-n">Name</label>
        <input id="f-n" name="name" type="text" autocomplete="name" required aria-required="true">
      </div>
      <div class="field">
        <label class="field__required" for="f-e">Email</label>
        <input id="f-e" name="email" type="email" autocomplete="email" required aria-required="true" aria-describedby="email-hint">
        <span id="email-hint" class="field__hint">We’ll never share your email.</span>
      </div>
      <div class="field">
        <label for="f-m">Mobile number</label>
        <input id="f-m" name="mobile" type="tel" autocomplete="tel">
      </div>
      <div class="field field--full">
        <label for="f-msg">Message</label>
        <textarea id="f-msg" name="message" rows="4" aria-describedby="msg-hint"></textarea>
        <span id="msg-hint" class="field__hint">Optional — grade, board, or questions.</span>
      </div>
      <button type="submit" class="btn btn--navy" style="justify-self: start">Send message</button>
    </form>
  </div>
</section>
