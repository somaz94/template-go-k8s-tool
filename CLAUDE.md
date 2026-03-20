# CLAUDE.md — YOUR_PROJECT

A Kubernetes controller built with Kubebuilder (controller-runtime).

## Build & Test

```bash
make build           # Build manager binary
make test            # Run unit tests with envtest
make cover           # Generate coverage report
make fmt             # go fmt
make vet             # go vet
make manifests       # Generate CRD, RBAC manifests
make generate        # Generate DeepCopy methods
make docker-build    # Build Docker image
make deploy          # Deploy to cluster
make undeploy        # Remove from cluster
```

## Commit Guidelines

- Do not include `Co-Authored-By` lines in commit messages.
- Use Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ci:`, `chore:`)
- Do not push to remote. Only commit. The user will push manually.

## Project Structure

```
cmd/main.go                    # Entry point (controller-runtime manager)
api/v1/
  types.go                     # CRD spec/status definitions
  groupversion_info.go         # GroupVersion registration
internal/controller/
  myresource_controller.go     # Reconciler logic
  myresource_controller_test.go
config/
  crd/bases/                   # Generated CRD YAML
  default/                     # Kustomize overlay (namespace, patches)
  manager/                     # Deployment manifest
  rbac/                        # RBAC roles and bindings
  samples/                     # Example CR YAML
hack/
  boilerplate.go.txt           # License header for generated code
```

## Key Concepts

- **CRD**: MyResource (apiGroup: YOUR_GROUP.YOUR_DOMAIN/v1)
- **Reconciler**: Watches MyResource, reconciles desired state
- **Kustomize**: config/default builds full deployment manifests
- **Envtest**: Unit tests use controller-runtime envtest (fake API server)
- **Distroless**: Docker image uses gcr.io/distroless/static:nonroot

## Language

- Communicate with the user in Korean.
- All documentation and code comments must be written in English.
