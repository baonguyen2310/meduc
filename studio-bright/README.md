# Meduc Bright — white & red design preview

A separate, brighter color variant of Meduc Studio. Everything lives in `studio-bright/`; the original `studio/` and all existing Meduc pages remain unchanged. Layouts, content and demo interactions are retained, with pure-white page backgrounds, sharper neutral text, brighter brand-red accents and a more energetic leaderboard.

## Open locally

Run from this folder:

```sh
python3 -m http.server 4174 --bind 127.0.0.1
```

Then open `http://127.0.0.1:4174/index.html`. On a server already serving the Meduc repository, the separate paths are `/studio-bright/index.html`, `/studio-bright/courses.html`, etc. No build step, package install, database or internet connection is required for the demo itself. The optional OpenStax reference links require internet access.

## Suggested presentation route

1. `index.html` — full homepage narrative: promise, featured classes, teachers, learning paths, practice, community, journal, FAQ and final invitation.
2. `courses.html` — six classes, live text search, specialty and level filters, sort and saved classes.
3. `course_detail.html?id=clinical-thinking` — individualized course details, accessible tabs, curriculum, teacher, reviews and a three-part reading preview. Other supported IDs: `anatomy`, `surgery`, `ecg`, `physiology`, `examination`.
4. `instructors.html` — cinematic portrait gallery, specialty filters and individual teacher profiles.
5. `article_detail.html` — editorial reading layout, contents navigation, reading progress, save and copy link.
6. `leaderboard.html` — weekly/monthly rankings and school filters. Rankings are fictional demonstration snapshots, not a live points system.
7. `exams.html` — school → year → subject hierarchy, difficulty, search, save and resume. Six sample sets across two schools, backed by three distinct question banks.
8. `practice.html?exam=heart-hmu` — five true/false questions, answer feedback, explanation, references, notes, progress, results, review, wrong-answer retry and full retry.

## Demo boundaries

All people, titles, testimonials, reviews, prices, metrics and school associations are illustrative, disclosed in the footer. The three instructor portraits and the editorial library image were created using the built-in image generation tool. Full prompts and asset filenames are in `assets/images/PROMPTS.md`.

No authentication, purchases, email collection, payment gateway or backend writes. “Start learning” explains the preview and leads into the reading sample. There is no pretend video playback. Course saves, article saves, notes and practice sessions use the separate `meduc-bright:` localStorage namespace, so this variant does not change the original demo's saved progress even when both folders share an origin.

Question content is limited to basic anatomy/physiology and linked to the relevant OpenStax Anatomy & Physiology 2e sections. It is learning-demo content, not a clinical assessment or treatment tool.

## Structure

- Eight independent HTML entry points with shared styling and scripts.
- `assets/studio.css`: unmodified copy of the original layouts, components, mobile and reduced-motion support.
- `assets/bright.css`: new white/red palette, neutral photo treatment, higher-contrast controls, answer states and leaderboard styling; loaded after `studio.css` on all eight pages.
- `assets/data.js`: all fictional instructors, courses, rankings, exam sets and educational question banks.
- `assets/studio.js`: rendering and local interactions; no libraries or CDN dependencies.
- `assets/fonts/`: locally stored Be Vietnam Pro and Manrope font files from Google Fonts.
- `assets/images/`: locally stored generated JPEGs plus provenance/prompts.

Accessibility includes semantic landmarks, labels, keyboard-operable tabs, native modal focus trapping, visible focus states, live result messages and quiz shortcuts (1, 2, Enter). Native `dialog` requires a modern browser.

## Bright variant verification

- All eight pages render pure-white body backgrounds and load the new theme.
- All eight pages checked at 1280 px, 390 px and 320 px without document-level horizontal overflow or observed broken images.
- Visual checks cover every page, the homepage closing CTA, leaderboard podium and ranking table, and answer feedback.
- Weekly/monthly ranking order and school filtering checked.
- Correct/incorrect feedback remains readable after submission; progress survives reload. A full five-question session completed at 3/5, then full retry returned it to 0/5.
- Key palette pairs checked numerically: white on brand red 4.78:1, muted text on white 5.73:1, and pale-white podium text at least 4.52:1 across its gradient. This is a focused color check, not a full accessibility audit.
- No JavaScript errors observed during these browser checks.

## Original demo verification (inherited)

- JavaScript syntax checks pass for both shared scripts.
- All eight pages inspected in the local browser; no broken images observed.
- All eight layouts checked at 390 px and 320 px with no document-level horizontal overflow.
- Vietnamese search (including Đ/đ and unaccented uppercase input), category filters, saved-course filtering and empty results checked.
- Curriculum tabs, reading-preview steps, instructor filtering and profile dialogs checked.
- School → year → subject filtering checked against the resulting exam cards.
- Five-question session completed with 3/5 correct; review showed all five responses; retrying only two wrong answers returned 2/2; full retry returned to 0/5.
- Answer explanations and notes survived a page reload.
- Weekly/monthly ranking order and school filtering checked; article saving, homepage sample question and FAQ checked.
- No JavaScript errors observed during the tested browser flows.

The preview server serves only this standalone folder on loopback. Existing Meduc files remain unchanged.
