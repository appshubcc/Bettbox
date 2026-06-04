# Bettboxt Go server

This folder contains a minimal Go HTTP service.

Usage:
- Build locally: make build
- Run locally: make run (listens on :8080)
- Docker build: make docker-build

Endpoints:
- GET /health -> {"status":"ok"}
- GET /api/hello?name=yourname -> {"message":"hello yourname"}
