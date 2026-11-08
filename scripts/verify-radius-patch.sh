#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
patch_file="$repo_dir/arch/cutefish-desktop/001-set-corner-radius-8.patch"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone --depth=1 https://github.com/cutefishos/cutefish-toolkit.git "$tmp_dir/cutefish-toolkit"
cd "$tmp_dir/cutefish-toolkit"
patch --dry-run --forward --strip=1 --input="$patch_file"
printf '\nPatch applies cleanly to the current upstream main branch.\n'
