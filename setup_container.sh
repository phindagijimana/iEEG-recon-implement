#!/bin/bash
# Pull the iEEG-recon Apptainer/Singularity container from Docker Hub
set -euo pipefail

IEEG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_DIR="${IEEG_ROOT}/containers"
CONTAINER="${CONTAINER_DIR}/ieeg_recon_1.0.sif"

export APPTAINER_TMPDIR="${CONTAINER_DIR}/tmp"
export PROOT_TMP_DIR="${CONTAINER_DIR}/tmp"
export TMPDIR="${APPTAINER_TMPDIR}"
export APPTAINER_CACHEDIR="${CONTAINER_DIR}/cache"
mkdir -p "${APPTAINER_TMPDIR}" "${APPTAINER_CACHEDIR}"

if [[ -f "${CONTAINER}" ]]; then
    echo "Container already exists: ${CONTAINER}"
    ls -lh "${CONTAINER}"
    exit 0
fi

echo "Pulling lucasalf11/ieeg_recon:1.0 (this may take 15-30 min)..."
cd "${CONTAINER_DIR}"
apptainer pull "${CONTAINER}" docker://lucasalf11/ieeg_recon:1.0

echo "Done."
ls -lh "${CONTAINER}"
