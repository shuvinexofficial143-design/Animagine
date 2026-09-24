#!/usr/bin/env bash
set -e
sudo systemctl --no-pager --full status animagine || true
echo
curl -fsS http://127.0.0.1:8188/system_stats || true
