# runsd

Fork of ahmetb/runsd (resolves Cloud Run service names inside a container), maintained for security fixes.

- Read `docs/releasing.md` before changing `.github/workflows`, `.goreleaser.yml`, `.releaserc.json`, `Dockerfile` or `.github/dependabot.yml`, and before choosing a PR title (it decides the release).
- Build with `go build -o /dev/null ./runsd`; plain `go build ./...` fails because the package directory is named `runsd`.
- `go test ./...` calls real DNS (`TestDNSExternalRecursion` queries 8.8.8.8), so it needs internet.
