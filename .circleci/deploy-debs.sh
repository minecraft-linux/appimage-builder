#!/bin/bash
shopt -s nullglob
for f in $3/*.deb; do
  echo "Uploading: $f"
  curl -X POST -u "ci:$WEBSITE_CI_UPLOAD_PASS" --data-binary @"$f" -H "X-Type: $1" -H "X-Codename: $2" https://mcpelauncher.mrarm.io/api/v1/upload
  echo ""
done
