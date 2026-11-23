#!/bin/sh
# Run by the official entrypoint once, right after a new data directory is initialised: the empty, private key file (see nuit-key-file.sh).
set -eu
if [ ! -e "$PGDATA/server.key" ]; then umask 077; : > "$PGDATA/server.key"; chmod 600 "$PGDATA/server.key"; fi
