#!/bin/sh

setup

artisan="/usr/local/bin/php /var/www/artisan"
$artisan down
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

apache2-foreground
