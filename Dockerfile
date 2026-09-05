# syntax=docker/dockerfile:1

ARG IMAGE_GOLANG=docker.io/golang:1.27.1
FROM ${IMAGE_GOLANG} AS builder

# To let CI driven buildx pass build arguments
ARG TARGETOS
ARG TARGETARCH

# Set necessary environment variables
ENV CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH

# Build
RUN <<'EOF'
set -e
CGO_ENABLED=0 go install -trimpath -a -ldflags "-buildid= -w -s"  github.com/cespare/reflex@v0.3.1
EOF

FROM gcr.io/distroless/static-debian13:debug-nonroot@sha256:9852e038f47deba221ddd825a46095bbf77d5a222cd6106424dce8299cf8a649

COPY --chown=0:0 --chmod=0555 --from=builder /go/bin/reflex /app/reflex

WORKDIR /app

USER 65532:65532

ENTRYPOINT ["/app/reflex"]
CMD ["--help"]
