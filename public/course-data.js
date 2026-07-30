/* ==========================================================================
   G-TEC eLessons — course data
   --------------------------------------------------------------------------
   SOURCE OF TRUTH NOTE
   Grade 9 syllabus below is transcribed verbatim from the supplied PDF
   "CBSE (NCERT) GRADE 9 - LIST OF VIDEO CLASSES". Per-subject counts were
   re-derived by counting rows and match the PDF's own totals exactly
   (Maths 135, Physics 50, Chemistry 41, Biology 53, English 82 = 361).

   Two things to action, not to silently paper over:
   1. Chemistry contains one row marked "Rejected" (an internal QA note).
      It is flagged status:"rejected" here and filtered out of the public
      render, so the site shows 360 publishable lessons, not 361.
   2. `d` (duration) is intentionally absent. The PDF has no runtimes and
      inventing them would be worse than showing a gap. Populate `d` from
      the Vimeo/NestJS response and the UI picks it up with no other change.

   Replace this file with a fetch() to /api/courses when the backend is wired.
   ========================================================================== */

window.ELESSONS = (function () {

  /* --- pricing -------------------------------------------------------- */
  const FX = { INR: { sym: "₹", rate: 1 }, AED: { sym: "AED ", rate: 0.044 }, USD: { sym: "$", rate: 0.012 } };

  /* --- Grade 9 syllabus (verbatim from PDF) ---------------------------- */
  const G9 = {
    Mathematics: [
      { name: "Number Systems", v: ["Number Systems - Part 1", "Exercise 1.1; Irrational Numbers", "Exercise 1.2; Real Numbers and their Decimals - Part 1", "Real Numbers and their Decimals - Part 2; Exercise 1.3", "Exercise 1.3 Continued...", "Operations on Real Numbers", "Representing Real Numbers on Number line", "Identities; Example 16 to 18", "Exercise 1.5", "Laws of Exponents; Exercise 1.6 - Part 1", "Laws of Exponents; Exercise 1.6 - Part 2"] },
      { name: "Polynomials", v: ["Introduction", "Classification of Polynomial", "Zeros of a Polynomial - Part 1", "Zeros of a Polynomial - Part 2", "Remainder Theorem - Part 1", "Remainder Theorem - Part 2; Exercise 2.3", "Factorization of Polynomials - Part 1", "Factorization of Polynomials - Part 2; Exercise 2.4", "Exercise 2.4", "Exercise 2.4 Continued...", "Algebraic Identities", "Examples 16 to 20", "Examples 21 to 23", "Examples 24, 25; Exercise 2.5(1,2)", "Exercise 2.5 (3-5)", "Exercise 2.5 (6-8)", "Exercise 2.5 (9-14)", "Exercise 2.5 (15-16)"] },
      { name: "Coordinate Geometry", v: ["Introduction", "Exercise 3.1", "Exercise 3.2 and 3.3"] },
      { name: "Linear Equations in Two Variables", v: ["Introduction", "Exercise 4.1; Solution for Linear Equation; Examples (3,4)", "Exercise 4.2", "Graph of a Linear Equation in 2 Variable; Examples (5,6)", "Examples (7,8); Exercise 4.3(1)", "Exercise 4.3 (2-5)", "Exercise 4.3 (6-8)", "Equations of Lines Parallel to the x and y axis; Exercise 4.4"] },
      { name: "Introduction to Euclid's Geometry", v: ["Introduction", "Euclid's Axioms and Postulates; Theorem 5.1", "Exercise 5.1 (1 to 4)", "Exercise 5.1 (5 to 7); Equivalents of Euclid's 5th Postulate; Exercise 5.2 (1,2)"] },
      { name: "Lines and Angles", v: ["Introduction", "Adjacent Angles; Vertically Opposite Angles", "Theorem 6.1; Examples 1,2,3", "Exercise 6.1 (1 to 6)", "Parallel and Transversal Lines; Axiom 6.3 and Theorem 6.2", "Theorem 6.3 to 6.6", "Example 4,5,6", "Exercise 6.2 (1 to 6)", "Theorem 6.7, 6.8; Example 7, 8", "Exercise 6.3 (1 to 6)"] },
      { name: "Triangles", v: ["Introduction", "Criteria for Congruence of Triangles", "ASA Congruence Rule", "Theorem 7.2, 7.3, 7.4, 7.5, Example 1", "Example 2,3,4,5,6", "Exercise 7.1 (1,2,3,4,5)", "Exercise 7.1 (6,7,8)", "Exercise 7.2 (1,2,3,4,5,6,7,8)", "Examples 7, 8", "Exercise 7.3", "Inequalities in a Triangle; Theorem 7.6, 7.7 and 7.8", "Example 9; Exercise 7.4 (1,2)", "Exercise 7.4 (3,4,5,6)"] },
      { name: "Quadrilaterals", v: ["Introduction", "Properties of Parallelogram; Theorem 8.2, 8.3, 8.4, 8.5", "Theorem 8.6, 8.7, 8.8, Example 1", "Example 2,3,4,5,6", "Exercise 8.1 (1 to 4)", "Exercise 8.1 (5 to 7)", "Exercise 8.1 (8,9,10)", "Exercise 8.1 (11,12)", "Mid-Point Theorem and Converse of the Mid-Point Theorem", "Exercise 8.2 (1,2,3)", "Exercise 8.2 (4,5,6,7)"] },
      { name: "Areas of Parallelograms and Triangles", v: ["Introduction", "Exercise 9.1; Theorem 9.1", "Example 1,2; Exercise 9.2 (1)", "Exercise 9.2 (2,3,4)", "Exercise 9.2 (5,6); Theorem 9.2", "Formula for Area of a Triangle; Example (3,4); Exercise 9.3(1,2,3)", "Exercise 9.3 (4,5)", "Exercise 9.3 (6,7,8)", "Exercise 9.3 (9,10,11,12)", "Exercise 9.3 (13,14,15,16)"] },
      { name: "Circles", v: ["Introduction", "Exercise 10.1, Theorem 10.1", "Theorem 10.2; Perpendicular Bisector; Theorem (10.3,10.4); Exercise 10.2(1,2)", "Circle Through Three Point; Theorem 10.5; Example 1; Exercise 10.3 (1,2,3)", "Theorem 10.6, 10.7; Example 2; Exercise 10.4 (1,2)", "Exercise 10.4 (3,4,5,6)", "Theorem 10.8, 10.9, 10.10", "Theorem 10.11, 10.12", "Example 3, 4, 5, 6", "Exercise 10.5 (1,2,3,4,5,6)", "Exercise 10.5 (7,8,9,10,11,12)"] },
      { name: "Constructions", v: ["Introduction", "Constructions 11.2, 11.3", "Exercise 11.1 (1,2)", "Exercise 11.1 (3)", "Exercise 11.1 (4)", "Exercise 11.1 (5); Construction 11.4", "Constructions 11.5 Case 1 and 2; Construction 11.6", "Example 1; Exercise 11.2 (1)", "Exercise 11.2 (2,3)", "Exercise 11.2 (4,5)"] },
      { name: "Heron's Formula", v: ["Introduction", "Example 3; Exercise 12.1 (1 to 6)", "Applications of Heron's Formula; Example 4,5,6", "Exercise 12.2 (1,2,3,4)", "Exercise 12.2 (5,6,7,8,9)"] },
      { name: "Surface Areas and Volumes", v: ["Introduction", "Exercise 13.1 (1 to 6)", "Exercise 13.1 (7,8); Right Circular Cylinder; Exercise 13.2(1,2)", "Exercise 13.2 (3 to 11)", "Right Circular Cone; Exercise 13.3 (1 to 8)", "Sphere; Exercise 13.4 (1 to 9)", "Exercise 13.5 (1 to 7)", "Exercise 13.5 (8,9); Exercise 13.6 (1,2,3,8); Exercise 13.7 (1,6,7)", "Exercise 13.6 (4,5,6,7)", "Exercise 13.7 (2 to 9)", "Exercise 13.8 (1 to 10)", "Worked out Examples"] },
      { name: "Statistics", v: ["Introduction; Exercise 14.1(1,2); Example (1,2)", "Presentation of Data; Example 3,4; Exercise 14.2(1,2)", "Exercise 14.2 (3 to 7)", "Exercise 14.2 (8,9); Exercise 14.3 (1,2)", "Exercise 14.3 (3 to 6)", "Exercise 14.3 (7 to 9)", "Central tendency of Data (Mean, Median & Mode); Exercise 14.4 (1 to 6)"] },
      { name: "Probability", v: ["Introduction; Example (1 & 2)", "Example 3; Exercise 15.1(1,2,4,5,7,11,13)"] }
    ],
    Physics: [
      { name: "Motion", v: ["Describing Motion", "Motion along the Straight Line; Uniform and Non-Uniform Motion", "Measuring Rate of a Motion", "Rate of Change of Velocity", "Graphical Representation of Motion - Distance Time Graph", "Exercises", "Velocity - Time Graph", "Equations of Motion by Graphical Methods", "Equation for Velocity - Time Graph", "Activity 8.9, 8.10", "Questions on Page 103", "Examples 8.5, 8.6, 8.7", "Questions on Page 109,110", "Uniform Circular Motion and Recap", "Recap Continued..."] },
      { name: "Force and Laws of Motion", v: ["Introduction", "First Law of Motion", "Inertia and Mass", "Second Law of Motion", "Solved Problems", "Solved Problems and Third Law of Motion", "Conservation of Momentum", "Solved Problems", "Example 9.5, 9.8, 4 on Page 127"] },
      { name: "Gravitation", v: ["Introduction", "Free Fall", "Solved Problems", "Mass, Weight", "Thrust and Pressure, Pressure in Fluids, Buoyancy", "Why objects Float or Sink? Example 10.4, 10.5", "Exercises on Page 143", "Exercises on Page 144", "Archimedes Principle; Relative Density"] },
      { name: "Work and Energy", v: ["Introduction", "Forms of Energy; Kinetic Energy", "Solved Problems - 1", "Potential Energy", "Law of Conservation of Energy", "Rate of Doing Work; Commercial Unit of Work; Solved Problems"] },
      { name: "Sound", v: ["Introduction", "Sound Needs a Medium to Travel; Characteristics of the Sound Wave", "Characteristics of a Sound Wave; Amplitude and Speed", "Example 12.1; Intext Questions - 3,4; Speed of Sound in Different Medium", "Reflection of Sound; Range of Hearing", "Applications of Ultrasound", "Solved Problems; Structure of the Ear", "Exercises (1,2,3,4,5,6)", "Exercises (7,8,9,10,11)", "Exercises (12,13,14,15)", "Exercises (16,17,18,20,21)"] }
    ],
    Chemistry: [
      { name: "Matter in our Surroundings", v: ["Introduction to Matter in our Surroundings", "States of Matter", "Change in States of Matter", "Evaporation", "Solving Questions - Part 1", "Solving Questions - Part 2", "Solving Questions - Part 3", "Solving Questions - Part 4", "Exercises - Part 1", "Exercises - Part 2", "Recap"] },
      { name: "Is Matter Around Us Pure", v: ["Introduction", "Types of Mixtures; Solutions", "Concentration of a Solution", "Suspensions and Colloids", "Colloids Explained", "In text Questions on Page 15 and 18", "Separating the Components of a Mixture - Part 1", "Separating the Components of a Mixture - Part 2", "Chromatography and Crystallization", "Physical and Chemical changes", { t: "Elements and Compounds", status: "rejected" }, "Text Book Questions", "Exercise 1,2 & 5", "Exercise 3", "Exercise 4,6,7,8,9,10,11"] },
      { name: "Atoms and Molecules", v: ["Introduction", "Atoms, Elements", "Modern Day Symbols of Atoms of Different Elements", "Atomic Mass", "Molecules of Elements and Compounds; Ions", "Writing Chemical Formula - Part 1", "Writing Chemical Formula - Part 2", "Molecular Mass and Mole Concept", "Example 3.3, 3.4, 3.5"] },
      { name: "Structure of Atom", v: ["Introduction", "Rutherford's Model of an Atom - Part 1", "Rutherford's Model of an Atom - Part 2", "Distribution of Electrons in Shells", "Valency (Combining Capacity)", "How to Calculate Valency?"] }
    ],
    Biology: [
      { name: "The Fundamental Unit of Life", v: ["Introduction", "Structural Organization of a Cell", "Plasma Membrane", "Plasma Membrane Continued...", "Nucleus", "Cytoplasm", "Organelles of the Cell - 1", "Organelles of the Cell - 2"] },
      { name: "Tissues", v: ["Tissues Introduction", "Section of the Stem", "Types of Plant Tissues", "Sclerenchyma Tissues and Epidermis", "Complex Tissues", "Animal Tissues", "Epithelial Tissues and Connective Tissue", "Cartilage, Areolar and Adipose Tissues", "Muscle Tissue", "Neuron"] },
      { name: "Diversity of Living Organism", v: ["Introduction", "Hierarchy of Classification; Binomial Nomenclature", "Kingdom Protista and Mycota", "Kingdom Plantae", "Kingdom Animalia - Phylum Porifera and Coelenterata", "Phylum Platyhelminthes, Nematoda and Annelida", "Phylum Arthropoda, Mollusca and Echinodermata", "Phylum Chordata - Group Protochordata and Vertebrates - Class Pisces", "Class - Amphibia, Reptilia, Aves and Mammalia"] },
      { name: "Why do We Fall Ill?", v: ["Introduction", "Health and Disease", "Disease and its Causes", "Causes of Diseases", "Infectious Diseases Caused by Viruses and Bacteria", "Means of Spread (Transmission)", "Organ Specific or Tissue Specific Manifestation and Treatment", "Principles and Prevention and Immunization"] },
      { name: "Natural Resources", v: ["Introduction", "Natural Resource - Air", "Rain, Air Pollution", "Water and Water Pollution", "Minerals and Formation of Soil", "Types of Soil; Soil Erosion; Water Cycle", "Nitrogen Cycle and Carbon Cycle", "Ozone Layer"] },
      { name: "Improvement in Food Resources", v: ["Introduction", "Crop Variety Improvements", "Crop Variety Improvements - Methods", "Crop Production Management - Part 1", "Crop Production Management - Part 2", "Crop Production Management - Part 3", "Crop Production Management - Part 4", "Animal Husbandry", "Poultry Farming", "Fish Production and Beekeeping"] }
    ],
    "English Grammar": [
      { name: "Alphabet", v: ["Vowels and Consonants"] },
      { name: "Parts of Speech", v: ["Parts of Speech", "Nouns", "Pronouns", "Adjectives", "Verbs", "Adverbs - 1", "Adverbs - 2", "Proposition - 1", "Preposition - 2", "Conjunctions"] },
      { name: "Types of Nouns", v: ["Introduction to Nouns and Proper Nouns", "Common Noun and Collective Noun", "Countable and Uncountable Nouns - Part 1", "Countable and Uncountable Nouns - Part 2", "Concrete and Abstract Nouns"] },
      { name: "Noun Gender", v: ["Noun Gender", "Neuter Gender"] },
      { name: "Noun Cases", v: ["Noun Cases", "Objective Case / Accusative Case", "Possessive Case", "Vocative Case"] },
      { name: "Noun Number", v: ["Noun Number - Singular - Plural Rules 1,2,3,4", "Noun Number - Singular - Plural Rules 1,2,3,4", "Noun Number - Singular - Plural Rules 11,12"] },
      { name: "Compound Nouns", v: ["Compound Nouns - Part 1", "Compound Nouns - Part 2", "Compound Nouns - Part 3"] },
      { name: "Articles", v: ["Articles - 1", "Articles - 2", 'Definite Article "THE" - Part 1', 'Definite Article "THE" - Part 2'] },
      { name: "Verb", v: ["Verb-1", "Verb-2", "Verb-3"] },
      { name: "Subject Verb Agreement", v: ["Subject Verb Agreement -1", "Subject Verb Agreement -2"] },
      { name: "Pronouns", v: ["Pronouns - Personal Pronouns", "Personal Pronouns as Subject and Object", "Relative Pronoun - Demonstrative Pronoun", "Indefinite Pronouns - 1", "Indefinite Pronouns - 2", "Reflexive Pronouns"] },
      { name: "Tenses", v: ["Tenses", "Present Tense - 1", "Present Tense - 2", "Past Tense - 1", "Past Tense - 2", "Future Tense"] },
      { name: "Figures of Speech", v: ["Figures of Speech - 1", "Figures of Speech - 2", "Figures of Speech - 3", "Figures of Speech - 4"] },
      { name: "Nouns", v: ["Proper Noun and Common Noun", "Types of Nouns"] },
      { name: "Adjectives", v: ["Adjectives - 1", "Adjectives - 2", "Adjectives - 3", "Types of Adjectives -1", "Types of Adjectives -2"] },
      { name: "Articles (Definite & Indefinite)", v: ["Indefinite Articles", "Definite Articles"] },
      { name: "Auxiliary Verbs", v: ["Auxiliary Verbs -1", "Auxiliary Verbs -2", "Auxiliary Verbs - 3"] },
      { name: "Sentences", v: ["The Sentence - Part 1", "The Sentence - Part 2", "Types of Sentences - Part 1", "Types of Sentences - Part 2"] },
      { name: "Phrases and Clauses", v: ["Types of Phrases", "Types of Clauses"] },
      { name: "Idioms", v: ["Idioms - Part 1", "Idioms - Part 2", "Idioms - Part 3", "Idioms - Part 4", "Idioms - Part 5"] },
      { name: "Question tags", v: ["Question tags"] },
      { name: "Parts of a Sentence", v: ["Parts of a Sentence -1", "Parts of a Sentence -2"] },
      { name: "Pronouns (Interrogative & Possessive)", v: ["Interrogative Pronoun", "Possessive Pronoun"] },
      { name: "Verbs", v: ["Main verbs; Auxiliary verbs"] }
    ]
  };

  /* Normalise: string | {t,status} -> {t, status, free}
     First lesson of each subject is set as the free preview. That is a
     product default I chose to mirror the existing /demo page — change
     `isFree` if marketing wants different preview lessons. */
  function normalise(subjects) {
    const out = {};
    Object.keys(subjects).forEach(function (sub) {
      let seen = 0;
      out[sub] = subjects[sub].map(function (ch) {
        return {
          name: ch.name,
          videos: ch.v.map(function (v) {
            const o = typeof v === "string" ? { t: v, status: "live" } : { t: v.t, status: v.status || "live" };
            if (o.status === "live") { seen++; o.free = seen === 1; }
            o.d = o.d || null;                 // duration: fill from video host
            return o;
          })
        };
      });
    });
    return out;
  }

  const syllabus = normalise(G9);

  function countLive(sub) {
    return syllabus[sub].reduce(function (n, ch) {
      return n + ch.videos.filter(function (v) { return v.status === "live"; }).length;
    }, 0);
  }

  /* --- catalogue -------------------------------------------------------- */
  const SUBJECT_PRICE = { Mathematics: 8000, Physics: 8000, Chemistry: 8000, Biology: 8000, "English Grammar": 0 };
  const MODULE_PRICE = 699;
  const LIVE_UPLIFT = 4000;   // Live + Recorded costs this much more than Recorded

  /* ASSUMPTION - CONFIRM BEFORE LAUNCH
     Grade 8 prices (8000 / 8000 / 4000 / 12000) are read off the live build
     and are applied unchanged to grades 9-12 here. Senior grades are very
     likely priced higher. MODULE_PRICE 699 and the 4000 live uplift come
     from the approved mockups, not from a live price list. */
  const catalogue = [];
  [8, 9, 10, 11, 12].forEach(function (g) {
    catalogue.push(
      { id: "g" + g + "-maths", grade: g, subject: "Maths", kind: "single", price: 8000, live: true, tagline: "Think. Solve. Succeed.", desc: "Concept clarity first, then problem solving — worked at the board, step by step." },
      { id: "g" + g + "-science", grade: g, subject: "Science", kind: "single", price: 8000, live: true, tagline: "Explore. Understand. Excel.", desc: "Physics, chemistry and biology, with the experiments that make each idea stick." },
      { id: "g" + g + "-english", grade: g, subject: "English", kind: "single", price: 4000, live: true, tagline: "Read. Write. Communicate.", desc: "Grammar, vocabulary, writing and literature — the four strands the paper tests." },
      { id: "g" + g + "-all", grade: g, subject: "All Subjects", kind: "bundle", price: 12000, was: 20000, live: true, tagline: "Everything, day one.", desc: "Maths, Science and English together for grade " + g + " — every lesson and every notes file, unlocked on day one." }
    );
  });

  /* --- reviews: paraphrased from testimonials published on elessons.net -- */
  const reviews = [
    { n: "Parent of a Grade 9 student", from: "Kochi, Kerala", r: 5, t: "Every NCERT topic is covered and the video and audio quality is genuinely good. The whole year is visible upfront, so a missed school class is easy to make up." },
    { n: "Grade 8 student", from: "Riyadh, Saudi Arabia", r: 5, t: "The full syllabus sits in my dashboard from day one along with the notes. I can read ahead before the topic comes up in school." },
    { n: "Parent of a Grade 10 student", from: "Dubai, UAE", r: 5, t: "No animation, no graphics — it is a teacher at a board, exactly like a classroom. That is what we were looking for, and the fee is modest." }
  ];

  const faqs = [
    { q: "How long does access last?", a: "Access runs to the end of the academic year you buy for. Recorded lessons stay open the whole time, so you can go back over a chapter as often as you need before an exam." },
    { q: "What is the difference between Recorded and Live + Recorded?", a: "Recorded gives you every lesson, notes and mock test to work through at your own pace. Live + Recorded adds scheduled classes with a mentor each week, and every live session is recorded and added to your library afterwards." },
    { q: "Can I buy one subject instead of the whole year?", a: "Yes. Use the By Subject tab to take a single subject, or By Module to take individual chapters. The full package is the cheaper route if you need three or more subjects." },
    { q: "Do I get printed or PDF notes?", a: "PDF notes are included with every subject and download from the same dashboard as the videos. Nothing is posted." },
    { q: "Is English Grammar charged separately?", a: "No. English Grammar is complimentary with the annual package — 82 lessons at no extra cost." },
    { q: "What do I need to watch the classes?", a: "Any phone, tablet or laptop with a browser and a working internet connection. There is nothing to install." },
    { q: "Can I switch from Recorded to Live later?", a: "Yes. Contact us on WhatsApp and you pay only the difference between the two plans for the remainder of the year." }
  ];

  return {
    FX: FX, catalogue: catalogue, syllabus: syllabus, reviews: reviews, faqs: faqs,
    countLive: countLive,
    MODULE_PRICE: MODULE_PRICE, LIVE_UPLIFT: LIVE_UPLIFT, SUBJECT_PRICE: SUBJECT_PRICE,
    WA_NUMBER: "919745553944",          // matches the number in the live header
    LMS_URL: "https://lms.elessons.net/login"
  };
})();
