# Development

Guide for building, testing, and contributing to this Kubernetes controller.

<br/>

## Prerequisites

- Go 1.26+
- Docker
- kubectl
- Make
- Access to a Kubernetes cluster (for e2e testing)

<br/>

## Build

```bash
make build           # Build binary → ./bin/manager
make docker-build    # Build Docker image
make docker-buildx   # Build and push multi-arch image
make clean           # Remove build artifacts
```

<br/>

## Code Generation

```bash
make manifests       # Generate CRD YAML, RBAC roles (controller-gen)
make generate        # Generate DeepCopy methods (controller-gen)
```

Always run these after modifying `api/v1/types.go` or RBAC markers.

<br/>

## Testing

```bash
make test            # Run unit tests with envtest
make cover           # Generate coverage report
make cover-html      # Open coverage in browser
```

<br/>

## Deployment

```bash
make install         # Install CRDs into cluster
make deploy          # Deploy controller to cluster
make undeploy        # Remove controller from cluster
make uninstall       # Remove CRDs from cluster
```

<br/>

## Workflow

```bash
make check-gh        # Verify gh CLI is installed and authenticated
make branch name=feature-name   # Create feature branch from main
make pr title="feat: add feature"   # Test → push → create PR
```

<br/>

## CI/CD Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `test.yml` | push (main), PR, dispatch | Unit tests → Manifests verify |
| `release.yml` | tag push `v*` | GitHub release |
| `changelog-generator.yml` | after release, PR merge | Auto-generate CHANGELOG.md |
| `contributors.yml` | after changelog | Auto-generate CONTRIBUTORS.md |
| `stale-issues.yml` | daily cron | Auto-close stale issues |
| `dependabot-auto-merge.yml` | PR (dependabot) | Auto-merge minor/patch updates |
| `issue-greeting.yml` | issue opened | Welcome message |

### Workflow Chain

```
tag push v* → Create release
                └→ Generate changelog
                      └→ Generate Contributors
```

<br/>

## Release

```bash
# Update image tag in Makefile
# Build and push Docker image
make docker-buildx

# Tag and push
git tag v0.1.0
git push origin v0.1.0
```

<br/>

## Conventions

- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ci:`, `chore:`)
- **CRD changes**: Always run `make manifests generate` after modifying types.go
- **paths-ignore**: CI skips `.github/workflows/**` and `**/*.md` changes
