/**
 * Rebuilds Grade 8 chapters from corrupted PDF extract and humanizes
 * glued titles (inOne → in One) across all registers in registers-generated.js.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import vm from 'vm';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FILE = path.join(__dirname, '../public/assets/js/registers-generated.js');

function humanize(s) {
  if (!s) return s;
  let t = String(s).replace(/\s+/g, ' ').trim();
  // Glue leftovers from PDF column splits onto the previous token when needed
  t = t.replace(/([a-z])([A-Z])/g, '$1 $2');
  t = t.replace(/([A-Za-z])(\d)/g, '$1 $2');
  t = t.replace(/(\d)([A-Za-z])/g, '$1 $2');
  // Common PDF glues without a capital break
  const pairs = [
    [/\bofa\b/gi, 'of a'],
    [/\bona\b/gi, 'on a'],
    [/\banda\b/gi, 'and a'],
    [/\btoa\b/gi, 'to a'],
    [/\bbya\b/gi, 'by a'],
    [/\bina\b/gi, 'in a'],
    [/\binan\b/gi, 'in an'],
    [/\bofan\b/gi, 'of an'],
    [/\bwitha\b/gi, 'with a'],
    [/\bfora\b/gi, 'for a'],
    [/\basa\b/gi, 'as a'],
    [/ofalgebraic/gi, 'of algebraic'],
    [/andalgebraic/gi, 'and algebraic'],
    [/andincluded/gi, 'and included'],
    [/aformula/gi, 'a formula'],
    [/afForce/gi, 'a Force'],
    [/afource/gi, 'a force'],
    [/aforce/gi, 'a force'],
    [/Due toan/gi, 'Due to an'],
    [/ANecessary/gi, 'A Necessary'],
    [/andinaudible/gi, 'and inaudible'],
    [/anglesofa/gi, 'angles of a'],
    [/Diagonalsofa/gi, 'Diagonals of a'],
    [/ARectangle/gi, 'A Rectangle'],
    [/ABar/gi, 'A Bar'],
    [/andarea/gi, 'and area'],
    [/OFPolygons/g, 'of Polygons'],
    [/\bTypesof\b/gi, 'Types of'],
    [/\bGroupingData\b/gi, 'Grouping Data'],
    [/\bGraphand\b/gi, 'Graph and'],
    [/\bEquallyLikely\b/gi, 'Equally Likely'],
    [/\bOutcomesas\b/gi, 'Outcomes as'],
    [/\bFindingThe\b/gi, 'Finding The'],
    [/\bFindingSquare\b/gi, 'Finding Square'],
    [/\bDivisionMethod\b/gi, 'Division Method'],
    [/\bCubeRoots\b/gi, 'Cube Roots'],
    [/\bCompoundinterest\b/gi, 'Compound interest'],
    [/\bCompoundedannually\b/gi, 'Compounded annually'],
    [/\bPricesRelated\b/gi, 'Prices Related'],
    [/\bEstimationin\b/gi, 'Estimation in'],
    [/\bAndLoss\b/gi, 'and Loss'],
    [/\bEdgesand\b/gi, 'Edges and'],
    [/\bofelectric\b/gi, 'of Electric'],
    [/\bandPressure\b/gi, 'and Pressure'],
    [/\bandThe\b/gi, 'and The'],
    [/\bandNon\b/gi, 'and Non'],
    [/\bandPl\b/gi, 'and Plastics'],
    [/\bandFl\b/gi, 'and Flame'],
    [/\bandFriend\b/gi, 'Friend'],
    [/\bofPlants\b/gi, 'of Plants'],
    [/\bofair\b/gi, 'of Air'],
    [/\bBasicPractices\b/gi, 'Basic Practices'],
    [/\bfromWeeds\b/gi, 'from Weeds'],
    [/\bfromanimals\b/gi, 'from Animals'],
    [/\bAndFoe\b/gi, 'and Foe'],
    [/\bMicroorganismsand\b/gi, 'Microorganisms and'],
    [/\bAnimalsDeforestation\b/gi, 'Animals. Deforestation'],
    [/\bConsequencesof\b/gi, 'Consequences of'],
    [/\bFunctionsThe\b/gi, 'Functions. The'],
    [/\bShapeand\b/gi, 'Shape and'],
    [/\binanimals\b/gi, 'in Animals'],
    [/\bofadolescence\b/gi, 'of Adolescence'],
    [/\bHormonesincompleting\b/gi, 'Hormones in Completing'],
    [/\btoDrugs\b/gi, 'to Drugs'],
    [/\binhumans\b/gi, 'in Humans'],
    [/\bPartsofa\b/gi, 'Parts of a'],
    [/\bFiguresof\b/gi, 'Figures of'],
    [/\bPartsof\b/gi, 'Parts of'],
    [/\bTypesofadjectives\b/gi, 'Types of Adjectives'],
    [/\bTypesofSentences\b/gi, 'Types of Sentences'],
    [/\bTypesofPhrases\b/gi, 'Types of Phrases'],
    [/\bTypesofClauses\b/gi, 'Types of Clauses'],
    [/\bTypesofNouns\b/gi, 'Types of Nouns'],
    [/\b&Rings\b/g, '& Rings'],
  ];
  for (const [re, rep] of pairs) t = t.replace(re, rep);
  t = t.replace(/\bOF\b/g, 'of');
  t = t.replace(/\s+/g, ' ').trim();
  // Clean leftover mid-word cutoffs
  t = t.replace(/\bAnd Plastics\b/i, 'and Plastics');
  t = t.replace(/\bAnd Flame\b/i, 'and Flame');
  return t;
}

function exNum(title) {
  const m = String(title).match(/Exercise\s*(\d+)\s*[.,]/i)
    || String(title).match(/\bEx[:\s]*(\d+)\s*[.,]/i)
    || String(title).match(/\b(\d+)\.(\d+)\b/);
  if (!m) return null;
  return parseInt(m[1], 10);
}

const MATH_MAP = [
  [1, 'Rational Numbers'],
  [2, 'Linear Equations in One Variable'],
  [3, 'Understanding Quadrilaterals'],
  [4, 'Practical Geometry'],
  [5, 'Data Handling'],
  [6, 'Squares and Square Roots'],
  [7, 'Cubes and Cube Roots'],
  [8, 'Comparing Quantities'],
  [9, 'Algebraic Expressions and Identities'],
  [10, 'Visualising Solid Shapes'],
  [11, 'Mensuration'],
  [12, 'Exponents and Powers'],
  [13, 'Direct and Inverse Proportions'],
  [14, 'Factorisation'],
  [15, 'Introduction to Graphs'],
  [16, 'Playing with Numbers'],
];

function rebuildMaths(chapters) {
  const flat = [];
  for (const ch of chapters) {
    for (const v of ch.v || []) flat.push(humanize(typeof v === 'string' ? v : v.t || ''));
  }
  // Drop junk
  const cleaned = flat.filter((t) => t && !/^name of videos$/i.test(t) && t.length > 1);

  const buckets = Object.fromEntries(MATH_MAP.map(([, name]) => [name, []]));
  let current = MATH_MAP[0][1];
  for (const title of cleaned) {
    const n = exNum(title);
    if (n && MATH_MAP.find(([ex]) => ex === n)) {
      current = MATH_MAP.find(([ex]) => ex === n)[1];
    } else {
      // Keyword routing when no exercise number
      const lower = title.toLowerCase();
      if (/rational number|number line|reciprocal|distributiv/.test(lower)) current = 'Rational Numbers';
      else if (/linear equation|variable on both|reducible to/.test(lower)) current = 'Linear Equations in One Variable';
      else if (/polygon|quadrilateral|parallelogram|rectangle|square(?!\s*root)/.test(lower)) current = 'Understanding Quadrilaterals';
      else if (/constructing a quadrilateral|practical geometry/.test(lower)) current = 'Practical Geometry';
      else if (/data|bar graph|pie chart|probability|chance/.test(lower) && !/exercise\s*1[56]/i.test(title)) current = 'Data Handling';
      else if (/square root|square number|pythagorean/.test(lower)) current = 'Squares and Square Roots';
      else if (/cube root|\bcube\b/.test(lower) && !/cuboid/.test(lower)) current = 'Cubes and Cube Roots';
      else if (/percent|discount|profit|loss|compound interest|ratio/.test(lower)) current = 'Comparing Quantities';
      else if (/algebraic|monomial|binomial|identity|identities/.test(lower)) current = 'Algebraic Expressions and Identities';
      else if (/3d|solid shape|faces, edges|mapping space/.test(lower)) current = 'Visualising Solid Shapes';
      else if (/trapezium|mensuration|surface area|volume of|cuboid|cylinder/.test(lower)) current = 'Mensuration';
      else if (/exponent|standard form|negative exponent/.test(lower)) current = 'Exponents and Powers';
      else if (/direct proportion|inverse proportion/.test(lower)) current = 'Direct and Inverse Proportions';
      else if (/factorisation|factors of|division of algebraic/.test(lower)) current = 'Factorisation';
      else if (/linear graph|line graph|bar graph|pie graph|introduction to graph/.test(lower)) current = 'Introduction to Graphs';
      else if (/playing with|divisibility|letters of digit|number in general/.test(lower)) current = 'Playing with Numbers';
    }
    if (!buckets[current]) buckets[current] = [];
    // skip duplicate consecutive intros that are pure "Introduction"
    buckets[current].push(title);
  }

  return MATH_MAP.map(([, name]) => ({
    c: name,
    v: dedupeVideos(buckets[name] || []),
  })).filter((ch) => ch.v.length);
}

function dedupeVideos(list) {
  const out = [];
  const seen = new Set();
  for (const t of list) {
    const key = t.toLowerCase();
    // keep exercise parts distinct; skip exact dupes
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(t);
  }
  return out;
}

function fixScienceStream(chapters, renameMap) {
  const out = [];
  for (let i = 0; i < chapters.length; i++) {
    let name = humanize(chapters[i].c);
    let vids = (chapters[i].v || []).map((v) => humanize(typeof v === 'string' ? v : v.t || ''));

    // Merge split chapter: "Chemical Effects of Electric" + "Current"
    if (/chemical effects of electric$/i.test(name) && chapters[i + 1] && /^current$/i.test(chapters[i + 1].c)) {
      name = 'Chemical Effects of Electric Current';
      vids = vids.concat((chapters[i + 1].v || []).map((v) => humanize(typeof v === 'string' ? v : v.t || '')));
      i++;
    }
    // Synthetic Fibres And Pl + Astics...
    if (/synthetic fibres and pl/i.test(name) || /synthetic fibres and plastics/i.test(name)) {
      name = 'Synthetic Fibres and Plastics';
      vids = vids.map((v) => v.replace(/^Astics/i, '').replace(/^astics/i, '').trim()).filter(Boolean);
      vids = vids.map((v) => (v.startsWith('Synthetic') ? v : v.replace(/^([A-Z])/, (m) => m)));
    }
    if (/materials:\s*metals andnon/i.test(name) || /metals and non/i.test(name)) {
      name = 'Materials: Metals and Non-Metals';
      vids = vids.map((v) => v.replace(/^\s*-\s*Metals/i, 'Metals').replace(/^MetalsPhysical/, 'Metals — Physical'));
    }
    if (/combustion and fl/i.test(name)) {
      name = 'Combustion and Flame';
      vids = vids.map((v) => v.replace(/^Ame/i, '').trim()).filter(Boolean);
    }
    if (/coal and petroleum/i.test(name)) name = 'Coal and Petroleum';
    if (/force and.?pressure/i.test(name)) name = 'Force and Pressure';
    if (/stars and.?the solar/i.test(name)) name = 'Stars and the Solar System';
    if (/microorganisms:?\s*friend/i.test(name)) {
      name = 'Microorganisms: Friend and Foe';
      vids = vids.map((v) => v.replace(/^and Foe/i, '').replace(/^AndFoe/i, '').trim()).filter(Boolean);
    }
    if (/conservation of.?plants/i.test(name)) {
      name = 'Conservation of Plants and Animals';
      vids = vids.map((v) => v.replace(/^Animals\.\s*/i, '').replace(/^Animals/i, '').trim()).filter(Boolean);
    }
    if (/cell\s*[—\-].*structure/i.test(name) || /cell —structure/i.test(name)) {
      name = 'Cell — Structure and Functions';
      vids = vids.map((v) => v.replace(/^Functions\.\s*/i, '').replace(/^Functions/i, '').trim()).filter(Boolean);
    }
    if (/reproduction in.?animals/i.test(name)) name = 'Reproduction in Animals';
    if (/reaching the age/i.test(name)) name = 'Reaching the Age of Adolescence';
    if (/pollution of.?air/i.test(name)) name = 'Pollution of Air and Water';
    if (/crop production/i.test(name)) name = 'Crop Production and Management';

    if (renameMap && renameMap[name]) name = renameMap[name];
    if (/^chapter names$/i.test(name)) continue;

    out.push({ c: name, v: dedupeVideos(vids.filter(Boolean)) });
  }
  return out.filter((ch) => ch.v.length);
}

function walkHumanizeRegister(reg) {
  if (!reg || typeof reg !== 'object') return reg;
  const out = {};
  for (const [k, chapters] of Object.entries(reg)) {
    if (!Array.isArray(chapters)) {
      out[k] = walkHumanizeRegister(chapters);
      continue;
    }
    out[k] = chapters.map((ch) => ({
      c: humanize(ch.c),
      v: (ch.v || []).map((v) => {
        if (typeof v === 'string') return humanize(v);
        return { ...v, t: humanize(v.t) };
      }),
    }));
  }
  return out;
}

function serializeRegister(name, obj, indent = '') {
  const lines = [`${indent}const ${name} = {`];
  for (const [key, chapters] of Object.entries(obj)) {
    lines.push(`${indent}  ${key}: [`);
    for (const ch of chapters) {
      const vids = (ch.v || []).map((v) => {
        const s = typeof v === 'string' ? v : v.t;
        return JSON.stringify(s);
      }).join(',');
      lines.push(`${indent}    { c: ${JSON.stringify(ch.c)}, v: [${vids}] },`);
    }
    lines.push(`${indent}  ],`);
  }
  lines.push(`${indent}};`);
  return lines.join('\n');
}

const src = fs.readFileSync(FILE, 'utf8');
const sandbox = {};
vm.runInNewContext(src.replace(/const /g, 'var '), sandbox);

// Rebuild grade 8
const r8 = sandbox.REGISTER_8;
r8.maths = rebuildMaths(r8.maths);
r8.physics = fixScienceStream(r8.physics);
r8.chemistry = fixScienceStream(r8.chemistry);
r8.biology = fixScienceStream(r8.biology);
r8.english = r8.english.map((ch) => ({
  c: humanize(ch.c),
  v: (ch.v || []).map((v) => humanize(typeof v === 'string' ? v : v.t || '')),
})).filter((ch) => !/^chapter names$/i.test(ch.c));

// Humanize other generated registers
const names = Object.keys(sandbox).filter((k) => k.startsWith('REGISTER_') && k !== 'REGISTER_8');
for (const n of names) {
  sandbox[n] = walkHumanizeRegister(sandbox[n]);
}

let out = '/* AUTO-GENERATED by scripts/parse-syllabus-pdfs.py — titles repaired by scripts/fix-register-titles.mjs */\n\n';
out += serializeRegister('REGISTER_8', r8) + '\n\n';
for (const n of names.sort()) {
  out += serializeRegister(n, sandbox[n]) + '\n\n';
}

fs.writeFileSync(FILE, out);
console.log('Wrote', FILE);
console.log('Grade 8 maths chapters:', r8.maths.map((c) => `${c.c} (${c.v.length})`).join(' | '));
console.log('Physics:', r8.physics.map((c) => c.c).join(' | '));
console.log('Chemistry:', r8.chemistry.map((c) => c.c).join(' | '));
console.log('Biology:', r8.biology.map((c) => c.c).join(' | '));
