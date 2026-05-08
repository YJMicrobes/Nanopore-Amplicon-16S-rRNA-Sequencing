#!/bin/bash

###############################################################################
# Nanopore 16S Amplicon Sequencing Analysis Pipeline
# Author: Yuan Jing
# Platform: Oxford Nanopore Technologies
# Kit: SQK-LSK114
# Target: Full-length 16S rRNA gene (27F/1492R)
###############################################################################

set -e
set -o pipefail

###############################################################################
# 1. Prepare Directories
###############################################################################

mkdir -p 0_pod5
mkdir -p 1_basecalling
mkdir -p 2_fasta
mkdir -p 3_demultiplex
mkdir -p 4_trimmed
mkdir -p 5_qc
mkdir -p 6_filtered
mkdir -p logs

###############################################################################
# 2. Basecalling with Dorado
###############################################################################

module load Dorado

echo "Downloading Dorado model..."

dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.0.0

echo "Starting basecalling..."

dorado basecaller \
    dna_r10.4.1_e8.2_400bps_sup@v5.0.0 \
    0_pod5/ \
    > 1_basecalling/amplicon.bam

###############################################################################
# 3. Convert BAM to FASTA
###############################################################################

module load samtools

echo "Converting BAM to FASTA..."

samtools fasta \
    1_basecalling/amplicon.bam \
    > 2_fasta/amplicon.fasta

###############################################################################
# 4. Demultiplexing with minibar
###############################################################################

module load minibar

echo "Demultiplexing reads..."

~/minibar-master/minibar.py \
    minibar.index \
    2_fasta/amplicon.fasta \
    -F \
    -P 3_demultiplex/rhi_minibar_

###############################################################################
# 5. Quality Statistics
###############################################################################

module load seqkit

echo "Generating sequence statistics..."

seqkit stats 3_demultiplex/*.fasta \
    > 5_qc/seqkit_stats.txt

###############################################################################
# 6. Primer Trimming with cutadapt
# Primers:
#   27F   = AGAGTTTGATCMTGGCTCAG
#   1492R = TACGGYTACCTTGTTACGACTT
###############################################################################

module load cutadapt/3.5

echo "Trimming primers..."

for file in 3_demultiplex/*.fastq
do
    sample=$(basename "$file" .fastq)

    cutadapt \
        -g AGAGTTTGATCMTGGCTCAG \
        -a TACGGYTACCTTGTTACGACTT \
        -o 4_trimmed/trimmed_${sample}.fastq \
        "$file" &
done

wait

echo "Primer trimming completed!"


###############################################################################
# 7. Quality Control with NanoPlot
###############################################################################

module load NanoPlot

echo "Running NanoPlot..."

for file in 4_trimmed/*.fastq
do
    sample=$(basename "$file" .fastq)

    NanoPlot \
        --fastq "$file" \
        -o 5_qc/${sample}_nanoplot &
done

wait

echo "NanoPlot analysis completed!"

###############################################################################
# 8. Quality Filtering with NanoFilt
###############################################################################

module load NanoFilt

echo "Filtering reads..."

for file in 4_trimmed/*.fastq
do
    sample=$(basename "$file" .fastq)

    NanoFilt \
        -q 10 \
        -l 1000 \
        < "$file" \
        > 6_filtered/${sample}_filtered.fastq &
done

wait

echo "NanoFilt filtering completed!"

###############################################################################
# 10. Downstream Analysis with mothur
###############################################################################

module mothur

echo "Running mothur batch analysis..."

mothur nanopore_amplicon_mothur.batch

###############################################################################
# Pipeline Complete
###############################################################################

echo "Pipeline completed successfully!"