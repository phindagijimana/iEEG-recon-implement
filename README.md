# iEEG-recon Implementation

Apptainer-based wrapper for the [iEEG-recon](https://github.com/penn-cnt/ieeg-recon) intracranial electrode reconstruction pipeline, configured for HPC (URMC Open OnDemand).

**Repository:** https://github.com/phindagijimana/iEEG-recon-implement

## Quick start

```bash
git clone https://github.com/phindagijimana/iEEG-recon-implement.git
cd iEEG-recon-implement

./EEG install    # sample data + container + models
./EEG start      # run modules 2+3 on sample subject
./EEG logs       # view latest run log
./EEG status     # check install state
```

## CLI commands

| Command | Description |
|---|---|
| `./EEG install` | Clone upstream repo, download sample data, pull Apptainer image, cache ANTsPyNet models |
| `./EEG start` | Run pipeline (defaults to `sub-RID0001`) |
| `./EEG logs [-f]` | Print latest log; `-f` to follow live |
| `./EEG status` | Show what is installed and whether a run is active |
| `./EEG help` | Show usage |

Pass extra args to `start` (forwarded to the container):

```bash
./EEG start -s sub-RID0001 -m 2          # module 2 only
BIDS_DIR=/path/to/BIDS ./EEG start -s sub-YOURID -rs ses-research3T -cs ses-clinical01
```

## What gets installed

`./EEG install` sets up:

1. **Upstream code** — clones [penn-cnt/ieeg-recon](https://github.com/penn-cnt/ieeg-recon)
2. **Sample dataset** — `sub-RID0001` (CT, MRI, VoxTool electrode labels) in `exampleData/BIDS/`
3. **Apptainer container** — `containers/ieeg_recon_1.0.sif` (~4 GB)
4. **ANTsPyNet models** — pre-cached weights in `containers/antsxnet_cache/`

## Project layout

```
.
├── EEG                    # Main CLI (install / start / logs)
├── run_ieeg_recon.sh      # Low-level Apptainer runner
├── setup_sample_data.sh   # Download example BIDS data
├── setup_container.sh     # Pull Apptainer image
├── setup_antsxnet_models.sh
├── SETUP.md               # Detailed HPC setup notes
├── iEEG.md                # Paper summary
├── exampleData/           # Sample data (created by install)
├── containers/            # SIF image + model cache (created by install)
└── logs/                  # Run logs (created by start)
```

## Requirements

- Apptainer/Singularity
- `curl`, `unzip`, `git`
- `gdown` (installed automatically for sample data download)
- ~8 GB RAM, ~5 GB disk for container + models

See [SETUP.md](SETUP.md) for HPC-specific notes (noexec `/tmp`, `PROOT_TMP_DIR`, etc.).

## Pipeline overview

| Module | Description | This wrapper |
|---|---|---|
| **1 — VoxTool** | Manual electrode labeling (GUI) | Use sample data labels, or run VoxTool separately |
| **2 — Registration** | CT → MRI co-registration | `./EEG start -m 2` |
| **3 — ROI assignment** | Atlas-based brain region labels | `./EEG start -m 3` |

Default `./EEG start` runs **modules 2 and 3** on the bundled sample subject.

## Outputs

After a successful run on the sample subject:

- QA report: `exampleData/BIDS/sub-RID0001/derivatives/ieeg_recon/module2/*_report.html`
- Electrode coordinates (MRI space): `.../module2/*_desc-mm_electrodes.txt`
- ROI assignments: `.../module3/*_atlas-DKTantspynet_radius-2_desc-vox_coordinates.txt`

## Reference

Lucas A, et al. *iEEG-recon: A fast and scalable pipeline for accurate reconstruction of intracranial electrodes and implantable devices.* Epilepsia. 2024. [DOI: 10.1111/epi.17863](https://doi.org/10.1111/epi.17863)

Upstream docs: https://ieeg-recon.readthedocs.io
