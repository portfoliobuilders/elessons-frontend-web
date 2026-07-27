@props([
    'grade' => '8',
    'stream' => 'All subjects',
    'subjects' => [],
    'price' => 'AED 1,200',
    'meta' => 'full academic year · all subjects',
    'banner' => 'var(--navy-600)',
    'tags' => '',
    'href' => '#contact',
])

<article
    class="course-card"
    data-tags="{{ $tags }}"
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
        <a href="{{ $href }}" class="btn btn--primary btn--sm btn--block">Buy now</a>
    </div>
</article>
