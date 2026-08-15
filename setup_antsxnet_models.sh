#!/bin/bash
# Pre-download ANTsPyNet model weights needed for Module 3 (-apn)
set -euo pipefail

IEEG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="${IEEG_ROOT}/containers/antsxnet_cache"
mkdir -p "${CACHE}"

declare -A MODELS=(
  [brainExtractionRobustT1.h5]="https://ndownloader.figshare.com/files/34821874"
  [dktInner.h5]="https://ndownloader.figshare.com/files/23266943"
  [dktOuter.h5]="https://ndownloader.figshare.com/files/23765132"
  [dktOuterWithSpatialPriors.h5]="https://ndownloader.figshare.com/files/24230768"
  [sixTissueOctantBrainSegmentation.h5]="https://ndownloader.figshare.com/files/23776025"
)

for f in "${!MODELS[@]}"; do
  dest="${CACHE}/${f}"
  if [[ -s "${dest}" ]]; then
    echo "Already present: ${f}"
    continue
  fi
  echo "Downloading ${f} ..."
  curl -L --retry 3 -o "${dest}" "${MODELS[$f]}"
done

echo "ANTsPyNet cache ready at ${CACHE}"
ls -lh "${CACHE}"
