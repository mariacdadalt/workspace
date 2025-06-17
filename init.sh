#!/usr/bin/env bash
set -e

# Start Lando environment
lando start

# Install PHP dependencies
lando composer install

# Setup WordPress
lando wp core install \
  --url=wordpress.lndo.site \
  --title="Lando Multisite" \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com

# Enable multisite
lando wp core multisite-convert --title="Lando Multisite"
