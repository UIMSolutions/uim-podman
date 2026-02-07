# UIM Podman Server

REST server library for the UIM Podman client, built with D and vibe.d.

## Run

```bash
dub run :server --config=app
```

## Authentication

All requests require a bearer token in the Authorization header:

```
Authorization: Bearer <token>
```

## Configuration

Environment variables:

- UIM_PODMAN_API_TOKEN (required)
- UIM_PODMAN_HOST (default 127.0.0.1)
- UIM_PODMAN_PORT (default 8080)
- UIM_PODMAN_BASE_PATH (default /api/v1)
- UIM_PODMAN_ENDPOINT (default unix:///run/podman/podman.sock)
- UIM_PODMAN_API_VERSION (default v4.0.0)
- UIM_PODMAN_CORS_ORIGINS (comma-separated list, use * for any origin)
- UIM_PODMAN_CORS_HEADERS (default Authorization, Content-Type)
- UIM_PODMAN_CORS_METHODS (default GET, POST, DELETE, OPTIONS)
- UIM_PODMAN_CORS_MAX_AGE (default 600)

## Example

```bash
UIM_PODMAN_API_TOKEN=devtoken \
UIM_PODMAN_CORS_ORIGINS=http://localhost:5173 \
dub run :server --config=app
```

## Curl

```bash
curl -H "Authorization: Bearer devtoken" \
	http://127.0.0.1:8080/api/v1/containers
```

Create container:

```bash
curl -X POST \
	-H "Authorization: Bearer devtoken" \
	-H "Content-Type: application/json" \
	-d '{"name":"demo","config":{"Image":"alpine:latest","Cmd":["sleep","60"]}}' \
	http://127.0.0.1:8080/api/v1/containers
```

Start container:

```bash
curl -X POST \
	-H "Authorization: Bearer devtoken" \
	http://127.0.0.1:8080/api/v1/containers/demo/start
```
