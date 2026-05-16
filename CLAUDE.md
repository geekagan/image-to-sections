# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Publishing

This is an npm package. There is no build step — edits to `src/index.js` are published directly.

```bash
# Full publish (interactive: version bump → npm publish → git tag + push)
git checkout master
bash ./scripts/publish.sh

# Dry-run (simulates all steps without publishing or pushing)
bash ./scripts/publish.sh --dry-run
```

The publish script requires a clean git working tree. It auto-handles version comparison with the live npm registry, interactive semver bumping, git tagging, and browser-based npm OTP auth.

No lint or test commands are configured (`npm test` exits with error).

## Architecture

This is a **browser-only** ES Module library. It has zero dependencies and no bundler/transpiler — the source is published as-is.

**File layout:**
- `src/index.js` — all library logic lives here (single file)
- `index.js` — root re-export barrel for npm consumers (re-exports from `src/index.js`)
- `examples/` — browser HTML demos (excluded from npm)
- `assets/` — images used in README (excluded from npm)
- `docs/` — development documentation, e.g. `publish-guide.md` (excluded from npm)
- `scripts/` — release tooling (`publish.sh`); excluded from npm

**Core pipeline for image slicing (`getBigImageSectionFiles`):**
```
File → URL.createObjectURL → Image (load) → zoomImageForSection → getImageCanvasSections → canvasToImageFile[] → File[]
```

**API surface:**

| Function | Input | Output | Notes |
|---|---|---|---|
| `getBigImageSectionFiles` | `File`, options | `Promise<File[]>` | Main API; handles full pipeline |
| `imageFileToThumbFile` | `File`, options | `Promise<File>` | Proportional scale, no distortion |
| `imageToCanvas` | loaded `Image`, options | `HTMLCanvasElement` | Sync; distorted=false keeps aspect ratio |
| `getImageCanvasSections` | loaded `Image`, options | `HTMLCanvasElement[]` | Delegates to H or V based on `cutDirection` |
| `getImageCanvasSectionsH` | loaded `Image`, height | `HTMLCanvasElement[]` | Horizontal slicing |
| `getImageCanvasSectionsV` | loaded `Image`, width | `HTMLCanvasElement[]` | Vertical slicing |
| `canvasToBlob` | `HTMLCanvasElement` | `Promise<Blob>` | |
| `canvasToImageFile` | `HTMLCanvasElement`, options | `Promise<File>` | |

**Key behaviors:**
- When `cutDirection='horizontal'`, only `sectionHeight` governs slice size; `sectionWidth` is ignored (and vice versa for `'vertical'`).
- When `allowZoom=true`, both width and height apply: the image is proportionally rescaled before slicing.
- `URL.createObjectURL` is revoked immediately after the Image loads to avoid memory leaks.
- The last slice may be shorter than the configured size if the image dimension isn't evenly divisible.
- All browser Canvas/File/URL APIs are used directly — this library cannot run in Node.js.

**Branching:** active development happens on `v0-dev`; releases are cut from `master`.
