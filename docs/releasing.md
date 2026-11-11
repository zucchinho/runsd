# Releasing and CI

Facts about how releases and CI work that the workflow files don't state.

## What triggers a release

The squash-merge PR title is the commit on `master`, and semantic-release
reads it (`@semantic-release/commit-analyzer` defaults):

- `fix:` and `perf:` release a patch.
- `feat:` releases a minor (the version is below 1.0, and `feat` still bumps the minor).
- `!` or a `BREAKING CHANGE` footer releases a major.
- `ci:`, `docs:`, `chore:` and `test:` release nothing.

Dependabot's `gomod` PRs use the `fix` prefix, so merging one releases a patch.
The `semantic-title` check enforces conventional-commit PR titles.

## One workflow, two modes

`release.yml` runs on pushes to `master` (a real release) and on pull requests
(a dry run). The dry run is selected by `DRY_RUN`, set from the event name.

- Tags pushed with `GITHUB_TOKEN` don't trigger other workflows, so the tag job
  and the build jobs live in one workflow.
- A dry run builds a GoReleaser snapshot, verifies the checksum, then builds the
  image and runs the binary in it. It skips semantic-release, publishing,
  attestations and the GHCR push.
- A real release is the only test of: semantic-release, the GitHub Release
  upload, `gh release download` plus attestation verification, the GHCR push
  and both attestations. Keep changes to those steps small.

## Release notes

semantic-release generates the notes and passes them to GoReleaser with
`--release-notes`. GoReleaser only loads that file when the changelog step runs,
so `changelog.disable` must stay unset in `.goreleaser.yml` (a guard step in
`release.yml` fails the build otherwise).

## Immutable releases

Published releases are immutable: tags and assets can't be changed or deleted.
Fix a bad release forward with a new `fix:` release. Release notes can still be
edited with `gh release edit --notes-file`.

## Artifacts

- Release assets: `runsd` (linux/amd64, static) and `checksums.txt`.
- Image: `ghcr.io/zucchinho/runsd`, tagged `X.Y.Z` and `X.Y` (the minor tag moves
  with each patch). There is no `latest` tag. The `image` job builds it from the
  downloaded release asset, not from a second build, so the image holds the
  released bytes.
- The binary and the image each carry a build provenance attestation.

## Pinning

- Every action is pinned by SHA with a `# vX.Y.Z` comment. The repo setting
  `sha_pinning_required` enforces this, so an unpinned action fails its workflow.
- Runners are pinned to `ubuntu-24.04`. Dependabot doesn't update `runs-on`; bump
  it by hand.
- `go.mod`'s `go` line is set by `go get -u` to the newest dependency minimum.
  CI builds with Go 1.27 and `check-latest`.

## Dependabot

- Cooldown is 7 days (14 for major) on `gomod`. `github-actions` takes only
  `default-days`: GitHub rejects `semver-major-days` there, and the schema check
  in CI doesn't catch that.
- `gomod` PRs use the `fix` prefix and `github-actions` PRs use `ci`, so their
  titles pass `semantic-title`.
