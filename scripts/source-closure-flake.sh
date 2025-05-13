#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq

set -euo pipefail

# First, we collect all the paths that will be necessary at *evaluation time*
# as otherwise, we couldn't evaluate everything on the offline machine later.
readarray -t evaluationPaths < <(nix flake archive --json | jq -r '.. | .path? | select(. != null)')

rootDerivation=$(nix-store -q -d "$(nix build --print-out-paths)")

# Now we do the following:
# 1. query the compile-time dependency tree of the image build
# 2. filter and keep only the fixed-output derivations
readarray -t sourceClosurePaths < <(nix derivation show -r |
  jq -r 'to_entries[] | select(.value.outputs.out.hash != null) | .key + " " + .value.outputs.out.path + " " + .value.env.urls')

mapfile -t sourceDrvPaths < <(printf "%s\n" "${sourceClosurePaths[@]}" | awk '{print $1}')
mapfile -t sourceOutPaths < <(printf "%s\n" "${sourceClosurePaths[@]}" | awk '{print $2}')

# we need to realize all these store paths to disk, otherwise we can't run any
# analysis on them
nix-store -r "${sourceDrvPaths[@]}" 2>/dev/null

closureSizes=()
for line in "${sourceClosurePaths[@]}"; do
  IFS=' ' read -r drvPath outPath url <<<"$line"
  sizeMb=$(du -sm "$outPath" 2>/dev/null | awk '{print $1}')
  closureSizes+=("$drvPath $outPath $url $sizeMb")
done

readarray -t sortedClosureSizes < <(printf "%s\n" "${closureSizes[@]}" | sort -nk4)

N=10
lastTenIndex=$((${#sortedClosureSizes[@]} - N))
if ((lastTenIndex < 0)); then
  lastTenIndex=0
fi

echo "$N biggest closure sizes:"

for line in "${sortedClosureSizes[@]:lastTenIndex}"; do
  IFS=' ' read -r drvPath outPath url sizeMb <<<"$line"
  printf '\nDownload: %s\nSize:     %s MB\nWhy do we depend on it:\n' "$url" "$sizeMb"
  nix why-depends "$rootDerivation" "$drvPath"
done

echo ""

mapfile -t sourceOutPaths < <(printf "%s\n" "${sourceClosurePaths[@]}" | awk '{print $2}')

# Exporting the evaluation time dependencies and the compile time source-only
# dependencies (which include the binary bootstrap tarball),
# this can later be imported in a secure offline environment and rebuilt
# from source
nix-store --export "${evaluationPaths[@]}" "${sourceOutPaths[@]}" \
  >source-export.closure

echo "Final source closure size: $(du -sh source-export.closure)"
