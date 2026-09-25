#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-/srv/network-os}"
output_dir="${2:-${HOME}}"
stamp="$(date +%Y-%m-%d)"
work_dir="$(mktemp -d)"
bundle_root="${work_dir}/network-os-repo-bundle"
archive="${output_dir}/network-os-repo-config-${stamp}.tar.gz"

trap 'rm -rf "${work_dir}"' EXIT

mkdir -p \
    "${bundle_root}/etc/nginx/sites-available" \
    "${bundle_root}/etc/nginx/conf.d" \
    "${bundle_root}/srv"

cp /etc/nginx/sites-available/network-os-repo \
    "${bundle_root}/etc/nginx/sites-available/"

cp /etc/nginx/conf.d/network-os-logging.conf \
    "${bundle_root}/etc/nginx/conf.d/"

while IFS= read -r directory; do
    relative="${directory#${repo_root}}"
    mkdir -p "${bundle_root}/srv/network-os${relative}"
done < <(find "${repo_root}" -type d | sort)

hostnamectl > "${bundle_root}/system-baseline.txt"
nginx -T > "${bundle_root}/nginx-effective-config.txt" 2>&1
find "${repo_root}" -type d | sort > "${bundle_root}/repository-layout.txt"

tar -C "${work_dir}" -czf "${archive}" network-os-repo-bundle
sha256sum "${archive}" > "${archive}.sha256"

echo "Created ${archive}"
echo "Created ${archive}.sha256"
