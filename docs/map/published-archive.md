# Published archive

## What it is

The set of files `flutter pub publish` uploads to pub.dev, decided by the
root `.pubignore`, the `.gitignore` files below the root, and pub's own
exclusions.

## Governing decisions

Issue #5: a root `.pubignore` leaves `docs/` and `CLAUDE.md` out of the
package, and `coverage/` with them (maintainer, 2026-11-02, chosen over a
one-line `docs/.pubignore`, which would have kept `CLAUDE.md` in the archive,
and over renaming or moving `docs/`, which breaks the skills that read
`docs/agents/thegraph.md`).

## Design model

- **The root `.pubignore` replaces the root `.gitignore` for pub.** For each
  directory pub uses its `.pubignore` if there is one, else its `.gitignore`
  (dart-lang/pub `lib/src/package.dart`, `listFiles`; same in the pub bundled
  with Dart 3.11.5). So the root `.pubignore` repeats every root
  `.gitignore` pattern. `example/.gitignore` and other lower `.gitignore`
  files still apply.
- **The plural-directory warning only sees published files.** pub's
  `DirectoryValidator` checks the top-level directory of each file in the
  archive, so an excluded `docs/` raises no "rename to doc" warning
  (`lib/src/validator/directory.dart`).
- Hidden files and directories and `pubspec.lock` stay out without a rule;
  the copied lines for them only keep the two lists identical.

## Traps

- **A pattern added to `.gitignore` and not to `.pubignore` ships.** Nothing
  warns. A `.pubignore` holding only `docs/` and `CLAUDE.md` passed the
  dry-run with 0 warnings while shipping an untracked root `build/`; with a
  real `build/` the archive grew from 509 KB to 14 MB (fresh-agent
  measurement, 2026-11-02). Read the dry-run's file list before a release.
- `coverage/` is not in `.gitignore`; before this file it shipped whenever
  `flutter test --coverage` had run (measured 2026-11-02).

## Code

- `.pubignore`
- `.gitignore`, `example/.gitignore`

## Cross-cutting invariants

**None.**
