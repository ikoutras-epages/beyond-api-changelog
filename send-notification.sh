#!/usr/bin/env bash

curl --user "api:${MAILGUN_API_TOKEN}" \
  https://api.eu.mailgun.net/v3/${MAILBOX}/messages \
  -F subject="Beyond API Changelog" \
  -F from="noreply@epages.com" \
  -F html="<-" "$@"
