@props([
    'grade' => '8',
    'stream' => 'All subjects',
    'subjects' => [],
    'price' => 'AED 1,200',
    'meta' => 'full academic year · all subjects',
    'banner' => 'var(--navy-600)',
    'tags' => '',
    'href' => null,
])

@php
    $wa = '971503980768';
    $msg = rawurlencode("Hi G-TEC eLessons, I want to buy the Grade {$grade} {$stream} annual package (AED 1200).");
    $buyHref = $href ?: "https://wa.me/{$wa}?text={$msg}";
    $label = "Buy Grade {$grade} {$stream} package on WhatsApp";
@endphp

<article
    class="course-card"
    data-tags="{{ $tags }}"
    data-grade="{{ $grade }}"
    data-stream="{{ $stream }}"
    style="--banner: {{ $banner }}"
    {{ $attributes }}
>
    <span class="course-card__ghost" aria-hidden="true">{{ $grade }}</span>
    <div class="course-card__head">
        <span class="course-card__grade">{{ $grade }}</span>
        <span class="course-card__stream">{{ $stream }}</span>
    </div>
    <div class="course-card__subjects">
        @foreach($subjects as $subject)
            <span class="course-card__chip">{{ $subject }}</span>
        @endforeach
    </div>
    <div class="course-card__foot">
        <p class="course-card__price">{{ $price }}</p>
        <p class="course-card__meta">{{ $meta }}</p>
        <a
            href="{{ $buyHref }}"
            class="btn btn--primary btn--sm btn--block"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="{{ $label }}"
        >Buy now</a>
    </div>
</article>
