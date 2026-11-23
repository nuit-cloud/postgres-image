#!/bin/sh
# Nuit Cloud: make sure the server's private key file exists and is private (0600, owned by postgres) before Postgres starts.
# Postgres accepts a key only with those rights, and nothing in SQL can create such a file; data-management then writes the
# Postgres service's certificate key into it through its admin session (nuit-cloud/nuit-cloud#202). Creates an empty file only
# when there is none; never reads, changes or removes an existing one. Runs as the image's entrypoint wrapper, as root or postgres.
set -eu
if [ -n "${PGDATA:-}" ] && [ -d "$PGDATA" ] && [ -f "$PGDATA/PG_VERSION" ] && [ ! -e "$PGDATA/server.key" ]; then
  umask 077
  : > "$PGDATA/server.key"
  if [ "$(id -u)" = 0 ]; then chown postgres:postgres "$PGDATA/server.key"; fi
  chmod 600 "$PGDATA/server.key"
fi
exec docker-entrypoint.sh "$@"
