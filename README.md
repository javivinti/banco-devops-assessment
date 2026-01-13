# Banco Pichincha - DevOps Assessment (Microservice)

This repository implements the requested **/DevOps** microservice and a local Kubernetes deployment (kind) with:
- API Key validation (`X-Parse-REST-API-Key`)
- JWT validation (`X-JWT-KWY`) + token generator endpoint (`GET /token`)
- Docker image build
- Kubernetes manifests with **2 replicas** + HPA
- CI pipeline (build + lint + tests + coverage)

## Requirements (local)

- Docker (Docker Desktop on Windows/Mac, or Docker Engine on Linux)
- `make`
- Linux/macOS terminal **or** Windows **WSL2** (recommended)

> Note: the `make up` script downloads `kubectl` and `kind` automatically into `.bin/` (local folder).

## Quick start (local Kubernetes with kind)

### 1) Start everything

```bash
make up
```

This will:
1. Build the docker image `banco-app:latest`
2. Create a kind cluster `banco-devops`
3. Load the image into the cluster
4. Apply manifests under `k8s/`
5. Port-forward nginx to `http://localhost:8000`

### 2) Get a JWT token

```bash
export HOST="http://localhost:8000"
export JWT="$(curl -s ${HOST}/token)"
echo "$JWT"
```

### 3) Test the required endpoint

```bash
curl -s -X POST   -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"   -H "X-JWT-KWY: ${JWT}"   -H "Content-Type: application/json"   -d '{ "message":"This is a test", "to":"Juan Perez", "from":"Rita Asturia", "timeToLifeSec":45 }'   "${HOST}/DevOps"
```

Expected output (example):

```json
{
  "message": "Hello Juan Perez your message will be send"
}
```

### 4) Run a full smoke test script

```bash
make test
```

### 5) Stop / clean local resources

```bash
make down
```

## API details

### `GET /token`
Returns a signed JWT token to be used in `X-JWT-KWY`.

### `POST /DevOps`
- Requires:
  - `X-Parse-REST-API-Key` header
  - `X-JWT-KWY` header (JWT)
- Body:
  - `message`, `to`, `from`, `timeToLifeSec`

### Other HTTP methods
Any method other than `POST` to `/DevOps` returns:
```json
{ "message": "ERROR" }
```

## Kubernetes

Manifests are under `k8s/`:
- `Deployment` for app with **replicas: 2**
- `HPA` for dynamic scaling (CPU-based)
- `nginx` reverse proxy (entrypoint for local access)

Local access is done using `kubectl port-forward svc/nginx 8000:80`.

## CI/CD

GitHub Actions workflow: `.github/workflows/ci.yml`

Stages:
- **Build**: `docker build`
- **Test**: ruff + pytest with coverage
- **Deploy** (main only): placeholder stage (ready to connect to AKS)

## (Optional) Cloud deployment with Terraform (Azure)

If you want to extend this project to Azure:
- Provision AKS + ACR with Terraform
- Push the built image to ACR
- Apply `k8s/` manifests referencing the ACR image
- Use `Service type: LoadBalancer` or an Ingress controller for external access

> Terraform is optional for the assessment, but recommended as an enhancement.
