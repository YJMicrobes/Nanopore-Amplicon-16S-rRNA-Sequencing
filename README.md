# Nanopore Full-Length 16S Amplicon Sequencing Pipeline

This repository contains a reproducible bioinformatics workflow for analyzing Oxford Nanopore full-length 16S rRNA amplicon sequencing data for microbial community profiling. The pipeline integrates basecalling, demultiplexing, quality control, primer trimming, and downstream microbial community analysis using mothur.

This workflow has been used in a peer-reviewed study. If you use this pipeline or any components of it, please cite the associated publication (see Citation section below).

------------------
## Overview

The pipeline includes two main stages:

### 1. Raw data processing
- Basecalling (Dorado)
- BAM to FASTA conversion
- Demultiplexing (minibar)
- Quality statistics (SeqKit)
- Primer trimming (cutadapt)
- Quality control (NanoPlot)
- Read filtering (NanoFilt)

### 2. Microbial community analysis
- FASTQ → FASTA conversion (mothur)
- Sequence merging and grouping
- Quality screening and alignment (SILVA database)
- Chimera detection (VSEARCH)
- Taxonomic classification
- ASV/OTU table generation


------------------
## Requirements

### Core software
- Dorado (Oxford Nanopore basecaller)
- samtools
- minibar
- seqkit
- cutadapt
- NanoPlot
- NanoFilt
- mothur
- VSEARCH


------------------
## ⚠️ Important Notes

### 1. GPU requirement for Dorado
Basecalling with Dorado requires a **GPU-enabled computing environment**.

If running on HPC:
- ensure GPU nodes are requested
- verify CUDA availability

Example (SLURM):

```
#SBATCH --gres=gpu:1
```
Without GPU access, basecalling will be extremely slow or may fail.



### 2. Module system dependencies

This pipeline assumes an HPC environment using the module system.

Before running, always check available software versions:

```
module avail
```

Then load appropriate modules:

```
module load Dorado
module load samtools
module load cutadapt
```
⚠️ Module names and versions may differ between systems.



### 3. No module system available?

If your system does not support module load, you can create a Conda environment instead:

```
conda create -n nanopore_env dorado samtools cutadapt seqkit mothur -c bioconda -c conda-forge
conda activate nanopore_env
```

Or install tools manually if required.


## Usage

#### Step 1: Run main pipeline
```
bash nanopore_amplicon_pipeline.sh
```

#### Step 2: Run mothur analysis
```
mothur nanopore_amplicon_mothur.batch
```



## Input data
POD5 files (raw Nanopore signal data)
Barcode demultiplexing index file (minibar.index)
Output structure
0_pod5/
1_basecalling/
2_fasta/
3_demultiplex/
4_trimmed/
5_qc/
6_filtered/
mothur_output/



## Methodological notes
- This pipeline is optimized for full-length 16S rRNA gene sequencing (27F–1492R).
- Designed for Oxford Nanopore Technologies long-read amplicon data.
- Supports multi-sample batch processing (e.g., 60+ samples).
- Uses ASV-like processing via mothur workflow.



## Citation

If you use this pipeline, please cite the following work:

> Ghribi, S., Degli Esposti, L., Steven, B., Zuverza-Mena, N., Yuan, J., LaReau, J., White, J. C., Jaisi, D. P., Adamiano, A., & Iafisco, M. (2025). Functionalization of amorphous and crystalline calcium phosphate nanoparticles with urea for phosphorus and nitrogen fertilizer applications. Journal of Agricultural and Food Chemistry. https://doi.org/10.1021/acs.jafc.5c03970

---

For the Nanopore metagenomic sequencing workflow, please see:

> Yuan, J., LaReau, J., Lawrence, B., Meadows-McDonnell, M., Steven, B., & Shabtai, I. (2026). Thresholds within a soil moisture gradient drive abrupt transitions in microbial community structure resulting in distinct carbon utilization patterns. Soil Ecology Letters. https://doi.org/10.1016/j.apsoil.2026.106966


## License

This project is released for academic use. Please contact the author for commercial use or collaboration.


## Contact

> Yuan Jing, Ph.D. \
> Microbial Ecology | Metagenomics | Microbiome Bioinformatics
