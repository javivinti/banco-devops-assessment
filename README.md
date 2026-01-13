# Banco Pichincha - DevOps Assessment (Microservice)

This repository implements the requested **/DevOps** microservice and a local Kubernetes deployment (kind) with:
- API Key validation (`X-Parse-REST-API-Key`)
- JWT validation (`X-JWT-KWY`) + token generator endpoint (`GET /token`)
- Docker image build
- Kubernetes manifests with **2 replicas** + HPA
- CI pipeline (build + lint + tests + coverage)

## Architecture

- Nginx acts as the entry point (**acting as a load balancer / reverse proxy**).
- Traffic is distributed across **2+ replicas** of the microservice via Kubernetes Service.
- HPA is enabled for dynamic scaling.



## Requirements (local)

- Docker ( Docker Engine on Linux)

- `make`
- Linux/macOS terminal **or** Windows **WSL2** (recommended)

> Note: the `make up` script downloads `kubectl` and `kind` automatically into `.bin/` (local folder).

### Installing requirements

- **Docker**:
```bash
curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker $USER
```

- **Make**:
  - Linux: usually available via package manager (e.g. `sudo apt install make`)

```bash
sudo apt install make
```

  - macOS: `xcode-select --install`
  - Windows (WSL2): `sudo apt install make`

- **WSL2 (Windows only)**:
  - https://learn.microsoft.com/windows/wsl/install


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

## Manual setup (without Make)

If you prefer not to use `make`, the project can be executed manually with the following steps.

### Installing Kubernetes tools (manual mode)

If you run the project without `make`, you need to install `kubectl` and `kind` manually.

- **kubectl**:
  - https://kubernetes.io/docs/tasks/tools/

  Example (Linux / WSL2):
```bash
 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 chmod +x kubectl
 sudo mv kubectl /usr/local/bin/kubectl
```
 - **kind**:
   -https://kind.sigs.k8s.io/docs/user/quick-start/

    Example (Linux / WSL2):
```bash
   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
```

### 1) Build the Docker image
```bash
docker build -t banco-app:latest .
```
### 2 ) Create the kind cluster
```bash
kind create cluster --name banco-devops
```
### 3 ) Load the image into the cluster
```bash
kind load docker-image banco-app:latest --name banco-devops
```
### 4 ) Apply Kubernetes manifests
```bash
kubectl apply -f k8s/
```
### 5 ) Apply Kubernetes manifests
```bash
kubectl port-forward svc/nginx 8000:80
```
### 6) Open new cmdand  Get a JWT token

```bash
export HOST="http://localhost:8000"
export JWT="$(curl -s ${HOST}/token)"
echo "$JWT"
```



Expected output (example):

```json
{
  "message": "Hello Juan Perez your message will be send"
}
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
- **Deploy (main only)**: placeholder stage, ready to be connected to a real Kubernetes environment (e.g. AKS).

## (Optional) Cloud deployment with Terraform (Azure)

If you want to extend this project to Azure:
- Provision AKS + ACR with Terraform
- Push the built image to ACR
- Apply `k8s/` manifests referencing the ACR image
- Use `Service type: LoadBalancer` or an Ingress controller for external access

> Terraform is optional for the assessment, but recommended as an enhancement.

## Testing notes

Some integration tests require the service to be running (API + Kubernetes).
For this reason, CI executes unit and API-level tests only.
Full end-to-end testing can be executed locally using `make up` followed by `make test`.

