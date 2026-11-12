# ui/dist build notes

Recorded for the 0.2.0 release (open-lex-it plan-c, blocks 25-29). The Host never builds; the committed `dist` is the registered artifact.

| Item | Value |
|---|---|
| Command | `npm ci && npm run build` |
| SDK | `@olx/package-ui-sdk` 0.2.2 from `vendor/olx-package-ui-sdk-0.2.2.tgz` (built from tag `v0.2.2` of `0ics-srls/package-ui-sdk`, see below) |
| `du -sb dist` | 494708 bytes (limit `PackageUi:MaxBytes` 5 MB) |
| `main.js` | 451502 bytes (limit per file 1.5 MB) |
| chunks | none (single bundle, no lazy chunks) |
| `styles.css` | 0 bytes (the package relies on the Host PrimeNG theme) |
| `3rdpartylicenses.txt` | 43188 bytes |
| `prerendered-routes.json` | 18 bytes |
| files in `dist` / tracked by git | 4 / 4 |
| `grep -c "zone.js" dist/main.js` | 0 (zoneless) |
| Custom elements | `dp-it-giurisprudenza-corpus`, `dp-it-giurisprudenza-decision`, `dp-it-giurisprudenza-status` (the SDK requires the prefix `dp-<package name>-`) |
| Determinism | a second `npm run build` leaves `git status --short ui/dist` empty (`outputHashing: none`); checked with md5 of the four files |

## How the SDK tarball was made

Tag `v0.2.2` of the SDK declares version 0.2.2 in both `package.json` files, so no version edit was needed. The tarball was built in a scratch clone, not in the submodule:

1. `git clone <package-ui-sdk submodule> scratch && git checkout v0.2.2`
2. `npm ci && npm run build:lib`
3. `npm pack` in `dist/package-ui-sdk` -> `olx-package-ui-sdk-0.2.2.tgz`, copied to `ui/vendor/`

`package-lock.json` is derived from the dp-it-normativa one (a fresh `npm install` against a tarball crashed there, P78-27); only the tarball entry (version, path, sha512) was re-pinned, and `npm ci` works.
