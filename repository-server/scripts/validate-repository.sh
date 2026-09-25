#!/usr/bin/env bash
set -euo pipefail

base_url="${1:-http://127.0.0.1}"
repo_root="${2:-/srv/network-os}"

required_dirs=(
    ciena/saos6/3916
    ciena/saos6/3922
    ciena/saos6/3924
    ciena/saos6/3930
    ciena/saos10/3924
    ciena/saos10/8114
    juniper/junos/mx-5
    juniper/junos/srx320
    manifests
)

for relative_dir in "${required_dirs[@]}"; do
    [[ -d "${repo_root}/${relative_dir}" ]] || {
        echo "Missing directory: ${repo_root}/${relative_dir}" >&2
        exit 1
    }
done

curl -fsSI "${base_url}/" >/dev/null

put_status="$(curl -sS -o /dev/null -w '%{http_code}'     -X PUT --data 'upload should fail' "${base_url}/upload-test")"

if [[ "${put_status}" != "403" && "${put_status}" != "405" ]]; then
    echo "Unexpected PUT response: ${put_status}" >&2
    exit 1
fi

echo "Directory structure: PASS"
echo "HTTP HEAD: PASS"
echo "Read-only PUT rejection: PASS (${put_status})"
