#!/usr/bin/env bash
set -e
sudo systemctl start animagine
sudo systemctl --no-pager --full status animagine
