# Meduc — dark hero study

A third, isolated design preview: **only the two-tier header and hero**, closely following the screenshot supplied by the user. Black background, a tall condensed Vietnamese headline, a seven-choice learning-goal form and two staggered moving portrait columns. No changes to `studio/`, `studio-bright/` or the existing Meduc pages.

## Run

```sh
python3 -m http.server 4175 --bind 127.0.0.1 --directory /Users/Shared/architecture/meduc/hero-dark
```

Open `http://127.0.0.1:4175/index.html`. When serving the project with its existing web server, use `/hero-dark/index.html`.

The hero itself is self-contained and works offline. Local-preview links open the existing Bright demo at port 4174. On a normal project server they use sibling paths under `/studio-bright/`. There are no account, payment or backend integrations.

## Reused assets — no new image generation

- `professor.jpg`, `doctor-linh.jpg`, `doctor-minh.jpg`: copied unchanged from `studio/assets/images/`; their generation provenance remains in that original folder's `PROMPTS.md`.
- The Meduc mark and wordmark reuse the existing Studio header treatment.
- Additional portrait photographs are the exact photo URLs already used in `home_masterclass.html`, now cached locally for a reliable preview:
  - `meduc-doctor-01.jpg`: `https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600&auto=format&fit=crop&q=80`
  - `meduc-doctor-02.jpg`: `https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600&auto=format&fit=crop&q=80`
  - `meduc-doctor-04.jpg`: `https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600&auto=format&fit=crop&q=80`
- Inter and Manrope reuse project font files. Anton is the Vietnamese-capable condensed headline face, sourced from [Google Fonts](https://fonts.google.com/specimen/Anton). Font license files are included locally.

Portraits are illustrative; the hero does not assign real people new names, affiliations or credentials.

## Interactions

- Browse menu with links to existing Meduc categories.
- Accent-insensitive course search with local, clickable results.
- Multiple learning-goal selection and a tailored set of demo links.
- An honest preview notice for the unconnected login action.
- Pause/play for the portrait strips, paused by default with reduced-motion preferences.
- Keyboard focus, Escape dismissal, native modal dialogs, responsive mobile header and search.

The preview collects no personal information and stores no account or goal data.

## Verification

- Visually compared at 1440 × 812 against the supplied 2880 × 1624 reference.
- Checked at 320, 390, 768, 1024, 1280, 1440 and 1920 px: no document-level horizontal overflow or broken portraits observed.
- Browse menu, Escape dismissal, mobile menu/search, accent-insensitive search, empty search results and the preview login dialog checked.
- Empty-goal validation and a two-goal recommendation flow checked; recommendations resolve to the existing Bright demo.
- Portrait pause/play state checked. Reduced-motion defaults are implemented without changing operating-system settings.
- JavaScript syntax checks pass; no browser console errors observed in the tested flows.
- Original Studio and Bright folders compared by SHA-256 against their pre-task manifests and left unchanged.
