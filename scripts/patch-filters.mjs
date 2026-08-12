import fs from 'fs';

const p = 'public/index.html';
let h = fs.readFileSync(p, 'utf8');

h = h.replace(
  /\.bundle-price\{font-weight:800;font-size:1\.6rem;letter-spacing:-.03em;color:#fff;line-height:1\.1;margin-top:\.1rem\}\r?\n\.bundle-save\{font-size:\.72rem;color:var\(--gold\);margin-top:\.25rem\}/,
  '.bundle-price{font-weight:800;font-size:1.6rem;letter-spacing:-.03em;color:#fff;line-height:1.1;margin-top:.1rem}'
);

h = h.replace(
  /<div class="mt4" id="course-filters">[\s\S]*?<!-- RENDER ONCE -->/,
  `    <div class="mt4" id="course-filters">
      <div class="filter-group" role="group" aria-label="Filter by grade" data-for="grade">
        <span class="filter-group-label mono">Grade</span>
        <button type="button" class="filter" aria-pressed="false" data-filter="Grade 8">Grade 8</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Grade 9">Grade 9</button>
        <button type="button" class="filter" aria-pressed="true" id="filter-default" data-filter="Grade 10">Grade 10</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Grade 11">Grade 11</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Grade 12">Grade 12</button>
      </div>
      <div class="filter-group" role="group" aria-label="Filter by stream" data-for="stream" hidden>
        <span class="filter-group-label mono">Stream</span>
        <button type="button" class="filter" aria-pressed="false" data-filter="PCMB">PCMB</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="PCMC">PCMC</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Commerce">Commerce</button>
      </div>
      <div class="filter-group" role="group" aria-label="Filter by subject" data-for="subject">
        <span class="filter-group-label mono">Subject</span>
        <button type="button" class="filter" aria-pressed="false" data-filter="Maths" data-grades="8,9,10,11,12">Maths</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Science" data-grades="8,9,10">Science</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="English" data-grades="8,9,10">English</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Physics" data-grades="11,12">Physics</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Chemistry" data-grades="11,12">Chemistry</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Biology" data-grades="11,12">Biology</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Computer Science" data-grades="11,12">Computer Science</button>
        <button type="button" class="filter" aria-pressed="false" data-filter="Accountancy" data-grades="11,12">Accountancy</button>
      </div>
    </div>

    <!-- RENDER ONCE -->`
);

const newJs = `(function(){
  var gradeKey = 'Grade 10';
  var subjectKey = null;
  var streamKey = null;
  var streamGroup = document.querySelector('#course-filters [data-for="stream"]');

  function hasTag(el, k){ return !k || (el.dataset.tags||'').split('|').indexOf(k)>-1; }
  function gradeNum(k){ var m = String(k||'').match(/Grade\\s*(\\d+)/i); return m ? m[1] : null; }

  function syncChipVisibility(){
    var g = gradeNum(gradeKey);
    var senior = g === '11' || g === '12';
    if (streamGroup) streamGroup.hidden = !senior;
    if (!senior) streamKey = null;
    document.querySelectorAll('#course-filters [data-for="subject"] .filter').forEach(function(btn){
      var allowed = (btn.getAttribute('data-grades')||'').split(',');
      var show = !g || !allowed[0] || allowed.indexOf(g) > -1;
      btn.hidden = !show;
      if (!show && btn.getAttribute('aria-pressed')==='true') {
        btn.setAttribute('aria-pressed','false');
        subjectKey = null;
      }
    });
  }

  function applyFilters(){
    syncChipVisibility();
    document.querySelectorAll('#course-grid > .course').forEach(function(c){
      var ok = hasTag(c, gradeKey);
      if (ok && subjectKey) ok = hasTag(c, subjectKey);
      if (ok && streamKey) ok = hasTag(c, streamKey);
      c.style.display = ok ? '' : 'none';
    });
    document.querySelectorAll('#course-grid > .course-stream-row').forEach(function(row){
      var rowShow = hasTag(row, gradeKey);
      if (rowShow && streamKey) rowShow = hasTag(row, streamKey);
      if (rowShow && subjectKey) rowShow = hasTag(row, subjectKey);
      row.style.display = rowShow ? '' : 'none';
      if (!rowShow) return;
      var anyVisible = false;
      row.querySelectorAll('.course').forEach(function(c){
        if (!subjectKey) { c.style.display = ''; anyVisible = true; return; }
        var show = hasTag(c, subjectKey);
        c.style.display = show ? '' : 'none';
        if (show) anyVisible = true;
      });
      if (!anyVisible) row.style.display = 'none';
    });
  }

  document.querySelectorAll('#course-filters .filter').forEach(function(f){
    f.addEventListener('click', function(){
      var key = f.getAttribute('data-filter') || f.textContent.trim();
      var group = f.closest('.filter-group');
      var kind = group && group.getAttribute('data-for');
      var wasOn = f.getAttribute('aria-pressed')==='true';
      group.querySelectorAll('.filter').forEach(function(o){ o.setAttribute('aria-pressed','false'); });
      if (kind === 'grade') {
        gradeKey = wasOn ? 'Grade 10' : key;
        if (!wasOn) f.setAttribute('aria-pressed','true');
        else {
          var def = document.getElementById('filter-default');
          if (def) def.setAttribute('aria-pressed','true');
          gradeKey = 'Grade 10';
        }
        subjectKey = null; streamKey = null;
        document.querySelectorAll('#course-filters [data-for="subject"] .filter, #course-filters [data-for="stream"] .filter')
          .forEach(function(o){ o.setAttribute('aria-pressed','false'); });
      } else if (kind === 'stream') {
        streamKey = wasOn ? null : key;
        if (!wasOn) f.setAttribute('aria-pressed','true');
      } else {
        subjectKey = wasOn ? null : key;
        if (!wasOn) f.setAttribute('aria-pressed','true');
      }
      applyFilters();
    });
  });

  applyFilters();
})();`;

h = h.replace(
  /document\.querySelectorAll\('\.filter'\)\.forEach\(function\(f\)\{[\s\S]*?\n\}\);/,
  newJs
);

if (!h.includes('.sr-only{')) {
  h = h.replace(
    '*,*::before,*::after{box-sizing:border-box}',
    '*,*::before,*::after{box-sizing:border-box}\n.sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}'
  );
}

fs.writeFileSync(p, h);
console.log('OK filters', h.includes('data-for="stream"'), h.includes('applyFilters'));
