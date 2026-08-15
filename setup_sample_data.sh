#!/bin/bash
# Download and extract the iEEG-recon example dataset from Google Drive
set -euo pipefail

IEEG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${IEEG_ROOT}/exampleData"
ZIP="${DATA_DIR}/ieeg_recon_example.zip"
GDRIVE_ID="13mbHbU9xpn5XZZenveywD6nxQbgZaJQU"
BIDS="${DATA_DIR}/BIDS"

mkdir -p "${DATA_DIR}"

if [[ -d "${BIDS}/sub-RID0001" ]]; then
    echo "Sample data already present at ${BIDS}"
    exit 0
fi

GDOWN="${HOME}/.local/bin/gdown"
if [[ ! -x "${GDOWN}" ]]; then
    echo "Installing gdown..."
    pip3 install --user gdown
fi

echo "Downloading example dataset (~266 MB)..."
"${GDOWN}" "${GDRIVE_ID}" -O "${ZIP}"

echo "Extracting..."
unzip -q -o "${ZIP}" -d "${DATA_DIR}"

ln -sfn ieeg_recon_example_data/BIDS "${BIDS}"

echo "Done. Sample subject: sub-RID0001"
find "${BIDS}/sub-RID0001" -type f ! -name '.DS_Store' | sort
