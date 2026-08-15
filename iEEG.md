# iEEG-recon: A Fast and Scalable Pipeline for Accurate Reconstruction of Intracranial Electrodes and Implantable Devices

**Citation:** Lucas A, Scheid BH, Pattnaik AR, et al. *Epilepsia*. 2024;65:817–829. DOI: 10.1111/epi.17863

**Authors:** Alfredo Lucas, Brittany H. Scheid, Akash R. Pattnaik, Ryan Gallagher, Marissa Mojena, Ashley Tranquille, Brian Prager, Ezequiel Gleichgerrcht, Ruxue Gong, Brian Litt, Kathryn A. Davis, Sandhitsu Das, Joel M. Stein, Nishant Sinha

**Institution:** Center for Neuroengineering and Therapeutics, University of Pennsylvania

---

## Problem Being Solved

In drug-resistant epilepsy, clinicians implant intracranial electrodes (iEEG) to localize epileptic networks. After implantation, the electrode positions must be confirmed on brain imaging — a process called **electrode reconstruction** (labeling + CT/MRI coregistration + brain region assignment).

Existing tools had three critical gaps:
- Steep learning curve for non-programmers
- Slow runtimes (~4+ hours), impractical for busy centers or multicenter trials
- Did not leverage modern deep learning for registration/segmentation

---

## What is iEEG-recon?

A **standalone, modular, open-source pipeline** for semiautomatic iEEG electrode reconstruction on brain MRI, compatible with both clinical and research workflows and deployable on cloud platforms.

- Available in **MATLAB and Python**
- Packaged as a **Docker container** for reproducibility and portability
- Full documentation: https://ieeg-recon.readthedocs.io

---

## Study Population

- **132 patients** with drug-resistant epilepsy from 2 centers:
  - Hospital of the University of Pennsylvania (HUP): n=109
  - Medical University of South Carolina (MUSC): n=23
- **Retrospective cohort:** 118 patients (2015–2023)
- **Prospective cohort:** 14 patients
- Implant types: ECoG (n=23), SEEG (n=75)
- Surgeries: Ablation, resection, RNS, DBS, VNS, no surgery

---

## Pipeline Architecture: 3 Sequential Modules

### Module 1 — Electrode Labeling (VoxTool)
- GUI-based tool (developed with UPenn Computational Memory Lab)
- User loads postimplant CT; intensity threshold highlights electrode contacts
- User manually enters labels, then clicks electrodes in a 3D viewer
- One-click interpolation for grid, strip, and depth electrodes
- Time: **20–35 min** per case (10–16 electrode contacts)

### Module 2 — CT-to-MRI Registration
- Registers postimplant CT to preimplant MRI (6 degrees of freedom: 3 rotation + 3 translation)
- CT is thresholded first so only skull and electrodes are visible
- Two registration options:
  - **Greedy** (recommended): faster, multiresolution, normalized mutual information
  - **FLIRT** (fallback): 640 histogram bins, mutual information cost function
- Generates electrode coordinates in MRI space
- Output: HTML quality assurance report + ITK-SNAP workspace for visual review
- Time: **~10 ± 4 min**

### Module 3 — Electrode Region-of-Interest (ROI) Assignment
- Assigns each electrode contact to a brain region using a chosen atlas
- Method: generates a sphere (user-defined radius) around each electrode; assigns region with highest overlap
- Also outputs a ranked list of percent overlaps for all contacted regions (flexible thresholding)
- Supported atlases:
  - Desikan–Killiany–Tourville (DKT) and Talairach from FreeSurfer
  - Standard MNI-space atlases (AAL, Schaefer, etc.) — 16 included
  - Specialized subcortical atlases: ASHS (hippocampus), THOMAS (thalamus)
- **ANTsPyNet** (deep learning, ~10 min) used by default instead of FreeSurfer (~5 h)
- Template space (MNI) registration via antsRegistration (same as fMRIPrep)

---

## Key Technical Features

### Brain-Shift Correction (ECoG)
- ECoG grids/strips shift inward due to craniotomy-related pressure changes
- iEEG-recon applies a **two-step nonlinear energy-minimization** algorithm
- Preserves inter-electrode distances while repositioning electrodes onto the pial surface
- Requires FreeSurfer recon-all output; applies only to grids/strips (not depth electrodes)

### Postsurgery Registration
- Registers postsurgical MRI (with resection cavity) back to preimplant MRI
- Identifies which electrode contacts were within the resected area
- Clinically useful for confirming overlap between resection and seizure onset zone (SOZ)

### Cloud Implementation
- Deployed on **AWS EC2** using a Docker container
- Ensures consistent execution across all collaborating sites
- Includes a **defacing option** to anonymize patient MRI/CT inputs and outputs

### BIDS Compatibility
- Uses Brain Imaging Data Structure (BIDS)-like naming convention
- Organizes data by subject ID (e.g., sub-PENN01) and session (e.g., ses-research3T)

---

## Results

### Speed
- Modules 2 + 3 (registration + ROI assignment): **~10 ± 4 min** (Greedy + ANTsPyNet)
- Full pipeline including VoxTool labeling: **~30 min total**
- Tested on standard laptops with minimum 8 GB RAM

### Electrode Localizations
- Results validated by board-certified neuroradiologist (visual inspection of postimplant MRI)
- Spatial distribution biased toward **left temporal lobe** (consistent with temporal lobe epilepsy cohort)
- Tissue distribution (2-mm radius):
  - White matter: 42.6 ± 13.5%
  - Gray matter: 32.7 ± 11.7%
  - CSF: 14.4 ± 8.5%
  - Outside brain: 9.2 ± 8.4%
- Top gray matter regions: left middle, inferior, and superior temporal gyri

### ANTsPyNet vs. FreeSurfer
- Electrode region assignments were **highly correlated** between ANTsPyNet and FreeSurfer (Pearson r = 0.96)
- ANTsPyNet: ~10 min vs. FreeSurfer: ~5 h (on same computing server)
- ANTsPyNet is the practical choice for clinical settings

### Robustness to Implantable Devices
- Tested on 9 patients with **Responsive Neurostimulation (RNS/NeuroPace)** devices
- Titanium case creates skull artifact that complicates CT-MRI skull alignment
- All 9 cases produced acceptable outputs (confirmed by neuroradiologist)
- Demonstrates robustness to imaging artifacts from intracranial devices

### Robustness to Prior Surgery
- 4 patients had prior resection; pipeline successfully registered and reconstructed electrode locations in all

---

## Clinical Applications

- **Presurgical planning:** Localize SOZ electrodes; identify overlap with eloquent cortex
- **Postsurgical confirmation:** Verify resection site overlaps with SOZ electrodes
- **RNS electrode confirmation:** Localize device and lead contacts post-implantation
- **Epilepsy surgery meetings:** Auto-generated quality assurance reports and visualizations

---

## Research Applications

- Bridging iEEG with structural MRI, diffusion tensor imaging, and resting-state fMRI
- Multimodal atlas-based studies (hippocampus, motor cortex, etc.)
- Federated/multicenter data analysis (BIDS format, COINSTAC-compatible)
- Standardized reproducible pipelines for large cohorts

---

## Advantages Over Existing Tools

| Feature | Existing Tools | iEEG-recon |
|---|---|---|
| Learning curve | High (scripting required) | Low (GUI + single command) |
| Runtime | ~4+ hours | ~30 min total |
| Scalability | Limited, closed-source options | Docker container, cloud-ready |
| Deep learning | No | ANTsPyNet segmentation |
| Open source | Partial | Fully open source |
| Cost | Some commercial (CURRY) | Free |

---

## Limitations

1. Validated only in **adult** epilepsy centers — pediatric populations not yet tested
2. Relies on external toolboxes (ANTsPyNet, Greedy) that may still be under development
3. **Not FDA-approved** — not yet validated for use in clinical decision-making

---

## Conclusions

iEEG-recon is a fast (~30 min), accurate, modular, and scalable open-source pipeline for intracranial electrode reconstruction. It lowers the barrier to clinical and research use through its GUI, Docker container, cloud deployment, and automated quality reports. ANTsPyNet-based segmentation matches FreeSurfer accuracy at a fraction of the runtime. The tool is validated on 132 patients across two epilepsy centers and is robust to prior surgery and implantable device artifacts.

**Open access:** https://ieeg-recon.readthedocs.io/en/latest/
