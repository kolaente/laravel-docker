#!/bin/sh

# Set default variables
if [ -z "$UID" ]; then
	UID=1000
fi
if [ -z "$GID" ]; then
	GID=1000
fi

usermod --non-unique --uid ${UID} www-data
groupmod --non-unique --gid ${GID} www-data

mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/views
mkdir -p /app/storage/framework/cache
mkdir -p /app/storage/framework/views

