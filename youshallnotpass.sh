#!/bin/bash
#
# Edit the three export values and run this file to start your server

export LOTR_SESSION_KEY="1324567"
export LOTR_REPO_PATH="/"
export LOTR_GAPPS_DOMAIN="microsoft.co.uk"

bundle exec rackup config.ru
