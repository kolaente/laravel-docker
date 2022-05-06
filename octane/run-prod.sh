#!/bin/sh

setup

artisan="/usr/local/bin/php /var/www/artisan"
$artisan down
$artisan clear
$artisan cache:clear

$artisan migrate --force

$artisan config:clear
$artisan config:cache

$artisan event:clear
$artisan event:cache

$artisan route:clear
$artisan route:cache

$artisan view:clear
$artisan view:cache

$artisan up

php -d variables_order=EGPCS /var/www/artisan octane:start --server=swoole --host=127.0.0.1 --port=8000 &

nginx -g 'daemon off;'
