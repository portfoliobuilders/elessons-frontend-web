@php
$packages = [
    ['grade' => '8', 'stream' => 'All subjects', 'subjects' => ['Physics','Chemistry','Maths','Biology','English'], 'tags' => 'Grade 8|Science|Commerce', 'banner' => 'var(--navy-600)'],
    ['grade' => '9', 'stream' => 'All subjects', 'subjects' => ['Physics','Chemistry','Maths','Biology','English'], 'tags' => 'Grade 9|Science|Commerce', 'banner' => 'var(--navy-600)'],
    ['grade' => '10', 'stream' => 'All subjects', 'subjects' => ['Physics','Chemistry','Maths','Biology','English'], 'tags' => 'Grade 10|Science|Commerce', 'banner' => 'var(--navy-600)'],
    ['grade' => '11', 'stream' => 'PCMB', 'subjects' => ['Physics','Chemistry','Maths','Biology'], 'tags' => 'Grade 11|Science', 'banner' => 'var(--sci)'],
    ['grade' => '12', 'stream' => 'PCMB', 'subjects' => ['Physics','Chemistry','Maths','Biology'], 'tags' => 'Grade 12|Science', 'banner' => 'var(--sci)'],
    ['grade' => '11', 'stream' => 'PCMC', 'subjects' => ['Physics','Chemistry','Maths','Computer Science'], 'tags' => 'Grade 11|Science', 'banner' => 'var(--sci)'],
    ['grade' => '12', 'stream' => 'PCMBC', 'subjects' => ['Physics','Chemistry','Maths','Biology','Computer Science'], 'tags' => 'Grade 12|Science', 'banner' => 'var(--sci)'],
    ['grade' => '11', 'stream' => 'Commerce', 'subjects' => ['Accountancy','Maths','English','Grammar'], 'tags' => 'Grade 11|Commerce', 'banner' => 'var(--com)'],
    ['grade' => '12', 'stream' => 'Commerce', 'subjects' => ['Accountancy','Maths','English','Grammar'], 'tags' => 'Grade 12|Commerce', 'banner' => 'var(--com)'],
];
@endphp

<section id="courses" class="sec" aria-labelledby="courses-heading">
  <div class="wrap">
    <div class="section-head">
      <div>
        <p class="section-eyebrow">Annual packages</p>
        <h2 id="courses-heading" class="h2" style="margin-top: var(--space-sm)">Nine packages. One price.</h2>
      </div>
      <p class="section-lead">Every package runs the full academic year and includes all subjects for that stream.</p>
    </div>

    <div class="course-filters" style="margin-top: var(--space-xl)" role="group" aria-label="Filter courses">
      @foreach(['All','Grade 8','Grade 9','Grade 10','Grade 11','Grade 12','Science','Commerce'] as $i => $filter)
        <button
          type="button"
          class="course-filters__btn"
          data-filter="{{ $filter }}"
          aria-pressed="{{ $i === 0 ? 'true' : 'false' }}"
        >{{ $filter }}</button>
      @endforeach
    </div>
    <p id="filter-status" class="filter-status" aria-live="polite">9 packages shown</p>

    <div class="course-grid" id="course-grid" style="margin-top: var(--space-xl)">
      @foreach($packages as $pkg)
        <x-course-card
          :grade="$pkg['grade']"
          :stream="$pkg['stream']"
          :subjects="$pkg['subjects']"
          :tags="$pkg['tags']"
          :banner="$pkg['banner']"
          price="AED 1,200"
          meta="≈ ₹27,500 · full academic year"
        />
      @endforeach
    </div>
  </div>
</section>
