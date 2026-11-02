# Dependency updates

## What it is

Dependabot's pub update PRs for the package root and `example/`, configured in
`.github/dependabot.yml`. No CI runs on them: the repository has no workflow,
so a Dependabot PR arrives unchecked.

## Governing decisions

Issue #1.

## Design model

- **Root: one PR per dependency, only when a release leaves the caret.** The
  entry is `increase-if-necessary`, and `/pubspec.lock` is gitignored, so there
  is no resolved version to refresh; a PR appears only when a release falls
  outside the current constraint. The root's only dependency is the dev
  dependency `flutter_lints`, which does not reach consumers.
- **`example/`: one grouped monthly PR.** `example/` goes into the pub.dev
  archive as files, but its constraints reach no consumer's resolution. It
  depends on the package through `path: ../`, which Dependabot does not update.
- **Riverpod majors are ignored in `example/`.** `flutter_riverpod`,
  `riverpod_annotation`, `riverpod_generator` and `riverpod_lint` stay on 2.x,
  and a move to 3.x is made by hand (issue #1).
- **The grouped `example/` PR does not raise the example's SDK floor.** It can
  bring a major whose SDK requirement is above `example/pubspec.yaml`'s
  `sdk:` constraint (cupertino_icons 2.0.0 needs Dart `^3.12.0` against the
  example's `^3.8.1`, read on pub.dev 2026-11-02). Such a PR is closed and
  replaced by a commit that raises the floor by hand, as `flutter_table_plus`
  did with its #197 (maintainer, 2026-11-02).
- **The Riverpod 2.x pin holds `build_runner` back without failing the run.**
  The first grouped run (#8, 2026-11-02) completed successfully and brought
  `cupertino_icons` 2.0.0 and `flutter_lints` 6.0.0. It did not touch
  `build_runner`. The two cannot resolve together: `build_runner` 2.17.1
  needs `analyzer >=14.3.0 <15.0.0` and `build >=5.0.0 <5.1.0`, while
  `riverpod_generator` 2.6.5, the last 2.x, needs `analyzer ^7.0.0` and
  `build ^2.0.0` (pub.dev, 2026-11-02).

## Code

- `.github/dependabot.yml`
- `example/pubspec.yaml`

## Cross-cutting invariants

**None.**
