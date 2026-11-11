# Carries the release binary so consumers can `COPY --from` it by digest.
# The binary is built by GoReleaser (static, CGO_ENABLED=0); see release.yml.
FROM scratch
COPY runsd /runsd
ENTRYPOINT ["/runsd"]
