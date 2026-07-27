@props([
    'href' => null,
    'type' => 'primary', // primary, secondary, ghost, ghost-dark, navy
    'size' => 'md', // sm, md, lg
    'block' => false,
    'buttonType' => 'button',
])

@php
    $classes = trim(implode(' ', array_filter([
        'btn',
        'btn--' . $type,
        $size !== 'md' ? 'btn--' . $size : null,
        $block ? 'btn--block' : null,
    ])));
@endphp

@if($href)
    <a href="{{ $href }}" {{ $attributes->merge(['class' => $classes]) }}>
        {{ $slot }}
    </a>
@else
    <button type="{{ $buttonType }}" {{ $attributes->merge(['class' => $classes]) }}>
        {{ $slot }}
    </button>
@endif
