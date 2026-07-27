{{-- Phase 9 — SEO, social, structured data --}}
@php
  $siteUrl = 'https://elessons.net';
  $title = 'G-TEC eLessons.net — Traditional chalk-board class from the comfort of your home';
  $description = 'CBSE / NCERT video lessons and notes for grades 8 to 12. A real teacher at a real board. AED 1200 for the full academic year.';
  $ogImage = $siteUrl . '/images/hero/model-suit-960w.jpg';
@endphp

<meta name="description" content="{{ $description }}">
<meta name="theme-color" content="#0F172A">
<meta name="color-scheme" content="light">
<meta name="referrer" content="strict-origin-when-cross-origin">
<meta name="robots" content="index,follow">
<link rel="canonical" href="{{ $siteUrl }}/">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/favicon.svg">

<meta property="og:type" content="website">
<meta property="og:site_name" content="G-TEC eLessons">
<meta property="og:locale" content="en_AE">
<meta property="og:url" content="{{ $siteUrl }}/">
<meta property="og:title" content="{{ $title }}">
<meta property="og:description" content="{{ $description }}">
<meta property="og:image" content="{{ $ogImage }}">
<meta property="og:image:width" content="960">
<meta property="og:image:height" content="993">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{{ $title }}">
<meta name="twitter:description" content="{{ $description }}">
<meta name="twitter:image" content="{{ $ogImage }}">

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "{{ $siteUrl }}/#org",
      "name": "G-TEC eLessons",
      "url": "{{ $siteUrl }}/",
      "email": "contact@elessons.net",
      "telephone": "+971568056001",
      "logo": "{{ $siteUrl }}/favicon.svg",
      "sameAs": ["https://wa.me/971568056001"]
    },
    {
      "@type": "WebSite",
      "@id": "{{ $siteUrl }}/#website",
      "url": "{{ $siteUrl }}/",
      "name": "G-TEC eLessons",
      "publisher": { "@id": "{{ $siteUrl }}/#org" },
      "inLanguage": "en"
    },
    {
      "@type": "Offer",
      "@id": "{{ $siteUrl }}/#annual-offer",
      "name": "Annual CBSE package",
      "description": "Full academic year video lessons and notes for one grade package.",
      "price": "1200.00",
      "priceCurrency": "AED",
      "availability": "https://schema.org/InStock",
      "url": "{{ $siteUrl }}/#courses",
      "seller": { "@id": "{{ $siteUrl }}/#org" }
    },
    {
      "@type": "FAQPage",
      "@id": "{{ $siteUrl }}/#faq",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "What exactly do I get for AED 1,200?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Every video lesson and every notes file for one grade package, for the full academic year."
          }
        },
        {
          "@type": "Question",
          "name": "How long do I have access?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Until the end of the academic year you enrolled for. The whole year unlocks the day you pay."
          }
        },
        {
          "@type": "Question",
          "name": "Do you follow NCERT?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes. Lessons and notes are mapped chapter by chapter to the NCERT textbooks for CBSE grades 8 to 12."
          }
        },
        {
          "@type": "Question",
          "name": "Can I pay in Indian rupees?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes. Prices are listed in AED; Indian cards, UPI and net banking are charged the equivalent in rupees at checkout."
          }
        },
        {
          "@type": "Question",
          "name": "Is there a free demo?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes. A sample lesson and sample notes page are available on the homepage. No sign-up needed to request a demo."
          }
        },
        {
          "@type": "Question",
          "name": "What if my child falls behind?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Nothing expires mid-year. Any lesson can be rewatched and notes stay downloadable throughout."
          }
        }
      ]
    }
  ]
}
</script>
