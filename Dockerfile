FROM alpine:3.21
COPY --from=curlimages/curl:99.99.99 /usr/bin/curl /usr/bin/curl
COPY app /app
ENTRYPOINT ["/app"]
