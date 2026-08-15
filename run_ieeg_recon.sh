#!/bin/bash
# iEEG-recon pipeline runner via Apptainer/Singularity
#
# Usage:
#   ./run_ieeg_recon.sh                          # run sample subject with defaults
#   ./run_ieeg_recon.sh -s sub-RID0001 -m 2      # run only module 2
#   ./run_ieeg_recon.sh --help                   # show container help

set -euo pipefail

IEEG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER="${IEEG_ROOT}/containers/ieeg_recon_1.0.sif"
CONTAINER_URI="docker://lucasalf11/ieeg_recon:1.0"
BIDS_DIR="${IEEG_ROOT}/exampleData/BIDS"

# Apptainer needs a writable temp dir (NFS /tmp may have noexec)
export APPTAINER_TMPDIR="${IEEG_ROOT}/containers/tmp"
export PROOT_TMP_DIR="${IEEG_ROOT}/containers/tmp"
export TMPDIR="${APPTAINER_TMPDIR}"
export APPTAINER_CACHEDIR="${IEEG_ROOT}/containers/cache"
mkdir -p "${APPTAINER_TMPDIR}" "${APPTAINER_CACHEDIR}"

if [[ ! -f "${CONTAINER}" ]]; then
    echo "WARNING: Local SIF not found at ${CONTAINER}"
    echo "Using ${CONTAINER_URI} (first run may take 30+ min to cache)"
    CONTAINER="${CONTAINER_URI}"
fi

if [[ ! -d "${BIDS_DIR}" ]]; then
    echo "ERROR: BIDS data not found at ${BIDS_DIR}"
    echo "Run: bash ${IEEG_ROOT}/setup_sample_data.sh"
    exit 1
fi

# Default args for the bundled sample subject
DEFAULT_ARGS=(
    -s sub-RID0001
    -d /source_data
    -rs ses-research3T
    -cs ses-clinical01
    -m -1
    -gc
    -apn
    -r 2
)

if [[ $# -eq 0 ]]; then
    set -- "${DEFAULT_ARGS[@]}"
fi

echo "=== iEEG-recon (Apptainer) ==="
echo "Container: ${CONTAINER}"
echo "BIDS mount: ${BIDS_DIR} -> /source_data"
echo "Command: apptainer run -B ${BIDS_DIR}:/source_data ${CONTAINER} $*"
echo ""

apptainer run \
    -B "${BIDS_DIR}:/source_data" \
    -B "${IEEG_ROOT}/containers/antsxnet_cache:${HOME}/.keras/ANTsXNet" \
    "${CONTAINER}" \
    "$@"
