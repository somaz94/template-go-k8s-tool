# Build stage
FROM golang:1.26 AS builder

ARG VERSION=dev
ARG GIT_COMMIT=none
ARG BUILD_DATE=unknown

WORKDIR /workspace

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY cmd/ cmd/
COPY api/ api/
COPY internal/ internal/

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X main.version=${VERSION} -X main.gitCommit=${GIT_COMMIT} -X main.buildDate=${BUILD_DATE}" \
    -o manager ./cmd/main.go

# Runtime stage
FROM gcr.io/distroless/static:nonroot

LABEL org.opencontainers.image.title="YOUR_PROJECT"
LABEL org.opencontainers.image.description="A brief description of your K8s controller"
LABEL org.opencontainers.image.url="https://github.com/YOUR_USERNAME/YOUR_PROJECT"
LABEL org.opencontainers.image.source="https://github.com/YOUR_USERNAME/YOUR_PROJECT"
LABEL org.opencontainers.image.licenses="Apache-2.0"

WORKDIR /
COPY --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
