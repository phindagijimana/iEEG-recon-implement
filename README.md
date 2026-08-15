# iEEG-recon Implementation

Apptainer-based wrapper for the [iEEG-recon](https://github.com/penn-cnt/ieeg-recon) intracranial electrode reconstruction pipeline, configured for HPC (URMC Open OnDemand).

## Quick start

```bash
./EEG install    # sample data + container + models
./EEG start      # run modules 2+3 on sample subject
./EEG logs       # view latest run log
./EEG status     # check install state
```

## Commands

| Command | Description |
|---|---|
| `./EEG install` | Clone upstream repo, download sample data, pull Apptainer image, cache ANTsPyNet models |
| `./EEG start` | Run pipeline (defaults to `sub-RID0001`) |
| `./EEG logs [-f]` | Print latest log; `-f` to follow live |
| `./EEG status` | Show what is installed and whether a run is active |

Pass extra args to `start` (forwarded to the container):

```bash
./EEG start -s sub-RID0001 -m 2          # module 2 only
BIDS_DIR=/path/to/BIDS ./EEG start -s sub-YOURID -rs ses-research3T -cs ses-clinical01
```

## Requirements

- Apptainer/Singularity
- `curl`, `unzip`
- `gdown` (installed automatically for sample data download)
- ~8 GB RAM, ~5 GB disk for container + models

See [SETUP.md](SETUP.md) for HPC-specific notes.

## Reference

Lucas A, et al. *iEEG-recon: A fast and scalable pipeline for accurate reconstruction of intracranial electrodes and implantable devices.* Epilepsia. 2024. [DOI: 10.1111/epi.17863](https://doi.org/10.1111/epi.17863)
