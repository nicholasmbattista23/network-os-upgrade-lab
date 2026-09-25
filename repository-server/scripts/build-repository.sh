#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

repo_root="${1:-/srv/network-os}"

install -d -m 0755     "${repo_root}/ciena/saos6/3916"     "${repo_root}/ciena/saos6/3922"     "${repo_root}/ciena/saos6/3924"     "${repo_root}/ciena/saos6/3930"     "${repo_root}/ciena/saos10/3924"     "${repo_root}/ciena/saos10/8114"     "${repo_root}/juniper/junos/mx-5"     "${repo_root}/juniper/junos/srx320"     "${repo_root}/manifests"

chown -R root:root "${repo_root}"
find "${repo_root}" -type d -exec chmod 0755 {} +

echo "Repository structure created under ${repo_root}"
