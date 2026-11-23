# The platform's object storage image (nuit-cloud/nuit-cloud#201): the platform's own MinIO build (ghcr.io/nuit-cloud/minio,
# RELEASE.2025-10-15T17-29-55Z, from github.com/nuit-cloud/minio; the same digest storage-management's DEFAULT_MINIO_IMAGE pins), plus one
# step that writes the TLS certificate and key from NUIT_TLS_CERT / NUIT_TLS_KEY to MinIO's certs directory as public.crt and private.key
# (shared/nuit-tls-files.sh), since a container service cannot mount files. MinIO serves TLS on its own port once both files are there.
# Nothing else changes: the same `minio server /data`, as root, with minio as PID 1.
# The certs directory is ${MINIO_CERTS_DIR:-/root/.minio/certs}. MinIO itself reads only its --certs-dir flag, not that variable: whoever sets
# MINIO_CERTS_DIR also passes `--certs-dir` with the same path. Built from the repository root (the build context every image here shares).
FROM ghcr.io/nuit-cloud/minio@sha256:0a6f7d6503bde458bf48fa20fb3c5cf4d24c102a79d053429efa77f3006e9825
COPY --chmod=0755 shared/nuit-tls-files.sh /usr/local/bin/nuit-tls-files.sh
ENTRYPOINT ["/bin/sh", "-c", "exec nuit-tls-files.sh \"${MINIO_CERTS_DIR:-/root/.minio/certs}\" public.crt private.key - minio \"$@\"", "minio"]
CMD ["server", "/data"]
