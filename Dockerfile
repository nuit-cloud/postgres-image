# The platform's Postgres image for database servers (nuit-cloud/nuit-cloud#201, #202): the official image, pinned by digest, plus one
# fixed step that creates an empty, private server.key in an initialised data directory. Postgres accepts a TLS key only from a private
# file and nothing in SQL can create one; data-management then writes the Postgres service's certificate and key into it through its
# admin session and reloads, on every renewal, without a restart. Nothing else is changed.
FROM postgres:17.6@sha256:00bc86618629af00d2937fdc5a5d63db3ff8450acf52f0636ec813c7f4902929
COPY --chmod=0755 nuit-key-file.sh /usr/local/bin/nuit-key-file.sh
COPY --chmod=0755 10-nuit-key-file.sh /docker-entrypoint-initdb.d/10-nuit-key-file.sh
ENTRYPOINT ["nuit-key-file.sh"]
CMD ["postgres"]
