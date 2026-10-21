#!/bin/sh

set -e

# Mitigation for GHSA-w8hw-w9fx-j79w / GHSA-6wmf-4rv5-p3rp: PHP's multipart parser
# can be driven OOM before the app runs. Derived from the installed stub so it
# can't drift from the Octane version.
CADDYFILE_STUB=/app/vendor/laravel/octane/src/Commands/stubs/Caddyfile
CADDYFILE=/tmp/Caddyfile
ANCHOR='^[[:space:]]*php_server {[[:space:]]*$'

if [ ! -f "$CADDYFILE_STUB" ]; then
    echo "error: Octane Caddyfile stub not found at $CADDYFILE_STUB, refusing to start without request filtering" >&2
    exit 1
fi
ANCHORS=$(grep -c "$ANCHOR" "$CADDYFILE_STUB" || true)
if [ "$ANCHORS" != "1" ]; then
    echo "error: expected exactly one 'php_server {' line in $CADDYFILE_STUB, found $ANCHORS, refusing to start without request filtering" >&2
    exit 1
fi
# (?i): PHP lowercases Content-Type before picking a body parser.
# request_body alone truncates oversized bodies and PHP still gets them as valid,
# so unknown-length bodies are refused and Content-Length is checked up front.
awk -v anchor="$ANCHOR" '$0 ~ anchor {
    print "\t\t@multipart header_regexp Content-Type (?i)multipart/"
    print "\t\trespond @multipart 415"
    print "\t\t@chunked header Transfer-Encoding *"
    print "\t\trespond @chunked 411"
    print "\t\t@nolength {"
    print "\t\t\tmethod POST PUT PATCH"
    print "\t\t\tnot header Content-Length *"
    print "\t\t}"
    print "\t\trespond @nolength 411"
    print "\t\t@oversized header_regexp Content-Length ^0*([1-9][0-9]{7,}|[89][0-9]{6})$"
    print "\t\trespond @oversized 413"
    print "\t\trequest_body {"
    print "\t\t\tmax_size 8MB"
    print "\t\t}"
    print ""
} { print }' "$CADDYFILE_STUB" > "$CADDYFILE"

setup

artisan-start /app/artisan

# FRANKENPHP_HTTPS=false opts out of TLS for https APP_URLs, for setups where
# a reverse proxy terminates TLS and --http-redirect would 308-loop.
HTTPS_FLAGS=""
PORT=80
HOST="0.0.0.0"
case "$APP_URL" in
    https://*)
        if [ "$FRANKENPHP_HTTPS" != "false" ]; then
            HTTPS_FLAGS="--https --http-redirect"
            PORT=443
            HOST="${SERVER_NAME:-localhost}"
            export OCTANE_HTTPS=true
        fi
        ;;
esac

exec php -d variables_order=EGPCS /app/artisan octane:start --server=frankenphp --host=$HOST --port=$PORT --admin-port 2019 --caddyfile=$CADDYFILE $HTTPS_FLAGS
