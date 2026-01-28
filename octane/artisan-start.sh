#!/bin/sh

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/artisan"
    exit 1
fi

artisan="/usr/local/bin/php $1"
$artisan down
$artisan clear

$artisan migrate --force

$artisan cache:clear

$artisan config:clear
$artisan config:cache

$artisan event:clear
$artisan event:cache

$artisan route:clear
$artisan route:cache

$artisan view:clear
$artisan view:cache

$artisan up
