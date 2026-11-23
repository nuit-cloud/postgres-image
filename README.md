# platform-images

The Nuit Cloud platform's own images (nuit-cloud/nuit-cloud#201): one folder and one image each, every one an upstream image pinned by
digest plus the least the platform needs on top. Each folder's `Dockerfile` is built from the repository root, so shared files are reachable.

| Folder | Published as | Upstream, pinned by digest |
|---|---|---|
| `postgres/` | `ghcr.io/nuit-cloud/postgres-image` | `postgres:17.6` |
| `openbao/` | `ghcr.io/nuit-cloud/openbao-store` | `openbao/openbao:2.7` (v2.7.3) |
| `minio/` | `ghcr.io/nuit-cloud/object-storage` | `ghcr.io/nuit-cloud/minio` (`RELEASE.2025-10-15T17-29-55Z`, the platform's own MinIO build) |

## postgres

Adds one fixed start-up step that creates an empty, private `server.key` (0600, owned by postgres) in an initialised data directory when
there is none. Postgres uses a TLS key only from a private file, and no SQL function can create one. data-management writes the Postgres
service's certificate and key into the existing file through its admin session and reloads Postgres, so renewals need no restart
(nuit-cloud/nuit-cloud#202). The step never reads, changes or removes an existing file, and nothing else differs from the official image.
data-management uses it through `DATABASE_SERVER_POSTGRES_IMAGE`. The image keeps its name from before this repository held more than one.

## openbao

Starts OpenBao as a real server (`server`, configured from `BAO_LOCAL_CONFIG` by the official entrypoint, which writes it to
`/openbao/config/local.json`), instead of the official image's dev server, and writes its TLS certificate and key from the environment.

## minio

The same `minio server /data`, plus writing its TLS certificate and key from the environment into MinIO's certs directory
(`${MINIO_CERTS_DIR:-/root/.minio/certs}`, as `public.crt` and `private.key`); MinIO serves TLS once both are there. MinIO reads only its
`--certs-dir` flag, not `MINIO_CERTS_DIR`: whoever sets the variable passes the flag with the same path.

## TLS from the environment (openbao, minio)

A container service cannot mount files, so the platform passes the certificate and key as secret references in `NUIT_TLS_CERT` and
`NUIT_TLS_KEY` (PEM). One small script, `shared/nuit-tls-files.sh`, copied into both images, writes them before the server starts:

- OpenBao: `/openbao/tls/tls.crt` and `/openbao/tls/tls.key`, owned by the openbao user. The platform's `BAO_LOCAL_CONFIG` names those
  paths in its `tcp` listener (`tls_cert_file`, `tls_key_file`).
- MinIO: `public.crt` and `private.key` in the certs directory, owned by root (MinIO runs as root).

The directory is 0700, the key 0600 and the certificate 0644. The values are never printed; both variables are removed from the environment
before the server is started, so the server process does not carry them. They do remain in the container's own configuration (what
`docker inspect` shows, and what `docker exec` starts with), as every variable passed to a container does. One variable without the other
is refused; with neither, nothing is written.

**A certificate renewal means restarting the service**: the files are written once, at start, from the values the service was started with.

## Publishing

Every push to `main` builds each image for amd64 and arm64, pushes it tagged `<upstream version>-<run>` and `sha-<commit>`, signs it by
digest (keyless cosign), and writes each published reference to the run's summary. A pull request builds without pushing. The upstream
version for each image is in `.github/workflows/image.yml`, beside the digest its `Dockerfile` pins: change the two together.
