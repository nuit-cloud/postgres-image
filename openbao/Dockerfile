# The platform's OpenBao image (nuit-cloud/nuit-cloud#201): the official openbao/openbao 2.7 (v2.7.3), pinned by digest, started as a real
# server instead of the image's dev server, plus one step that writes the TLS certificate and key from NUIT_TLS_CERT / NUIT_TLS_KEY to
# /openbao/tls/tls.crt and tls.key (shared/nuit-tls-files.sh), since a container service cannot mount files. The server is configured from
# BAO_LOCAL_CONFIG by the official entrypoint, unchanged (it writes the JSON to /openbao/config/local.json and runs
# `bao server -config=/openbao/config` as the openbao user under dumb-init); the platform's config names /openbao/tls/tls.crt and
# /openbao/tls/tls.key in its tcp listener. Built from the repository root (the build context every image here shares).
FROM openbao/openbao:2.7@sha256:ba4b133eb9586630024e71a617e66f37f29cc3534cdd46a6233e098ceded8dc9
USER root
COPY --chmod=0755 shared/nuit-tls-files.sh /usr/local/bin/nuit-tls-files.sh
RUN install -d -m 0700 -o openbao -g openbao /openbao/tls
USER openbao
ENTRYPOINT ["nuit-tls-files.sh", "/openbao/tls", "tls.crt", "tls.key", "openbao", "docker-entrypoint.sh"]
CMD ["server"]
