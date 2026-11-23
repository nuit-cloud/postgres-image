#!/bin/sh
# Nuit Cloud: write the service's TLS certificate and key from the environment into files, then start the image's own program.
#
#   nuit-tls-files.sh <dir> <cert-file> <key-file> <owner|-> <command> [args...]
#
# A container service cannot mount files, so the platform passes the certificate and key as secret references in NUIT_TLS_CERT and
# NUIT_TLS_KEY (PEM). When both are set, they are written to <dir>/<cert-file> and <dir>/<key-file> (the directory 0700, the key 0600,
# the certificate 0644; owned by <owner> when this runs as root, else by whoever runs it), both variables are removed from the
# environment, and <command> replaces this script. When neither is set, nothing is written and any files already there are left alone.
# One without the other is refused. The values are written with the shell's own printf, never on a command line, and never printed.
# A renewed certificate takes effect when the service restarts.
set -eu
[ "$#" -ge 5 ] || { echo "nuit-tls-files: usage: nuit-tls-files.sh <dir> <cert-file> <key-file> <owner|-> <command> [args...]" >&2; exit 64; }
dir="$1" cert="$2" key="$3" owner="$4"
shift 4

if [ -n "${NUIT_TLS_CERT:-}" ] || [ -n "${NUIT_TLS_KEY:-}" ]; then
  [ -n "${NUIT_TLS_CERT:-}" ] || { echo "nuit-tls-files: NUIT_TLS_KEY is set but NUIT_TLS_CERT is not; refusing to start" >&2; exit 78; }
  [ -n "${NUIT_TLS_KEY:-}" ] || { echo "nuit-tls-files: NUIT_TLS_CERT is set but NUIT_TLS_KEY is not; refusing to start" >&2; exit 78; }
  saved_umask="$(umask)"
  umask 077
  mkdir -p "$dir"
  chmod 700 "$dir"
  # written beside the final names and moved into place, so a half-written file is never what the server reads
  printf '%s\n' "$NUIT_TLS_KEY" > "$dir/.$key.tmp"
  chmod 600 "$dir/.$key.tmp"
  printf '%s\n' "$NUIT_TLS_CERT" > "$dir/.$cert.tmp"
  chmod 644 "$dir/.$cert.tmp"
  if [ "$(id -u)" = 0 ] && [ "$owner" != - ]; then chown "$owner:" "$dir" "$dir/.$key.tmp" "$dir/.$cert.tmp"; fi
  mv -f "$dir/.$key.tmp" "$dir/$key"
  mv -f "$dir/.$cert.tmp" "$dir/$cert"
  umask "$saved_umask"   # the image's own program starts with the umask it would have had
  echo "nuit-tls-files: wrote the TLS certificate and key to $dir" >&2
fi
unset NUIT_TLS_CERT NUIT_TLS_KEY
exec "$@"
