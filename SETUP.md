# iEEG-recon Setup (Apptainer on HPC)

This workspace contains the iEEG-recon pipeline configured to run via Apptainer/Singularity on the URMC HPC cluster.

## What's included

| Path | Description |
|---|---|
| `ieeg-recon/` | Source code (cloned from GitHub) |
| `exampleData/BIDS/` | Sample subject `sub-RID0001` (CT, MRI, VoxTool labels) |
| `containers/ieeg_recon_1.0.sif` | Apptainer image (after setup) |
| `setup_sample_data.sh` | Download example dataset |
| `setup_container.sh` | Pull Apptainer container |
| `setup_antsxnet_models.sh` | Pre-download ANTsPyNet weights for Module 3 |
| `run_ieeg_recon.sh` | Run pipeline on sample or custom data |
| `science.md` | Scientific theory of the pipeline (Modules 1–3) |
| `science.docx` | Word version of `science.md` |
| `iEEG.md` | Paper summary |

## Quick start

```bash
cd /mnt/nfs/home/urmc-sh.rochester.edu/pndagiji/Documents/iEEG

# 1. Sample data (already downloaded if sub-RID0001 exists)
bash setup_sample_data.sh

# 2. Container (~15-30 min first time; needs PROOT_TMP_DIR on this HPC)
bash setup_container.sh

# 3. ANTsPyNet model weights for Module 3 (recommended on HPC)
bash setup_antsxnet_models.sh

# 4. Run modules 2+3 on sample subject
./run_ieeg_recon.sh
```

## Sample data layout

```
exampleData/BIDS/sub-RID0001/
├── ses-clinical01/
│   ├── ct/sub-RID0001_ses-clinical01_acq-3D_space-T01ct_ct.nii.gz
│   └── ieeg/sub-RID0001_ses-clinical01_space-T01ct_desc-vox_electrodes.txt
└── ses-research3T/
    └── anat/sub-RID0001_ses-research3T_acq-3D_space-T00mri_T1w.nii.gz
```

## Run on your own data

Organize data in the same BIDS-like structure, then:

```bash
./run_ieeg_recon.sh \
  -s sub-YOURID \
  -d /source_data \
  -rs ses-research3T \
  -cs ses-clinical01 \
  -m -1 -gc -apn -r 2
```

Mount your BIDS directory by editing `BIDS_DIR` in `run_ieeg_recon.sh`, or override:

```bash
BIDS_DIR=/path/to/your/BIDS ./run_ieeg_recon.sh -s sub-YOURID ...
```

## HPC notes

- `/tmp` is mounted `noexec` on this cluster; scripts set `APPTAINER_TMPDIR` and `PROOT_TMP_DIR` to `containers/tmp` on NFS.
- First container pull takes ~45 min and produces a 4.1 GB SIF file.
- Module 3 (`-apn`) needs ANTsPyNet weights; run `setup_antsxnet_models.sh` to avoid Figshare download errors inside the container.
- Module 1 (VoxTool GUI) requires a display; Modules 2+3 run headless.
- Expected runtime for Modules 2+3: ~10 min per subject.

## References

- Paper: Lucas et al., *Epilepsia* 2024; DOI: 10.1111/epi.17863
- Theory: [science.md](science.md) / [science.docx](science.docx)
- Docs: https://ieeg-recon.readthedocs.io
- Container: `docker://lucasalf11/ieeg_recon:1.0`
