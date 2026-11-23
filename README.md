# postgres-image

The Nuit Cloud platform's Postgres image for database servers: the official `postgres:17.6` image, pinned by digest, plus one fixed
start-up step that creates an empty, private `server.key` (0600, owned by postgres) in an initialised data directory when there is none.

Why: Postgres uses a TLS key only from a private file, and no SQL function can create one. data-management writes the Postgres
service's certificate and key into the existing file through its admin session and reloads Postgres, so renewals need no restart
(nuit-cloud/nuit-cloud#202). The step never reads, changes or removes an existing file, and nothing else differs from the official image.

Every push to `main` builds amd64 and arm64, pushes `ghcr.io/nuit-cloud/postgres-image:17.6-<run>`, and signs it by digest (keyless
cosign). data-management uses it through `DATABASE_SERVER_POSTGRES_IMAGE`.
