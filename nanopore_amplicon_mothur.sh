###############################################################################
# Full-Length 16S Nanopore Amplicon Analysis Using mothur
#
# Platform: Oxford Nanopore Technologies
# Target: Full-length 16S rRNA gene
# Software: mothur
# Reference database: SILVA v138.1
###############################################################################

set.dir(input=6_filtered/)
set.dir(output=mothur_output/)

###############################################################################
# 1. Convert FASTQ to FASTA
###############################################################################
# Input:
#   *_filtered.fastq
#
# Output:
#   *.fasta
#   *.qual
###############################################################################

fastq.info(fastq=trimmed_barcode01_filtered.fastq)
fastq.info(fastq=trimmed_barcode02_filtered.fastq)
fastq.info(fastq=trimmed_barcode03_filtered.fastq)

# Continue for all samples...

###############################################################################
# 2. Create Group File
###############################################################################
# Output:
#   merge.count_table
###############################################################################

make.group(
    fasta=
    trimmed_barcode01_filtered.fasta-
    trimmed_barcode02_filtered.fasta-
    trimmed_barcode03_filtered.fasta,
    
    groups=
    sample01-
    sample02-
    sample03
)

###############################################################################
# 3. Merge FASTA Files
###############################################################################
# Output:
#   merge.fasta
###############################################################################

merge.files(
    input=
    trimmed_barcode01_filtered.fasta-
    trimmed_barcode02_filtered.fasta-
    trimmed_barcode03_filtered.fasta,
    
    output=merge.fasta
)

summary.seqs(
    fasta=merge.fasta,
    count=merge.count_table,
    processors=30
)

###############################################################################
# 4. Quality Screening
###############################################################################
# Remove:
#   ambiguous bases
#   overly long reads
#   excessive homopolymers
#
# Output:
#   merge.good.fasta
#   merge.good.count_table
###############################################################################

screen.seqs(
    fasta=merge.fasta,
    count=merge.count_table,
    maxambig=0,
    maxlength=1632,
    maxhomop=11
)

unique.seqs(
    fasta=current,
    count=current
)

summary.seqs(
    fasta=current,
    count=current
)

###############################################################################
# 5. Align Sequences to SILVA
###############################################################################
# Reference:
#   silva.nr_v138_1.align
#
# Output:
#   *.align
###############################################################################

align.seqs(
    fasta=current,
    reference=silva.nr_v138_1.align
)

summary.seqs(
    fasta=current,
    count=current
)

###############################################################################
# 6. Screen Aligned Sequences
###############################################################################
# Remove poorly aligned sequences
###############################################################################

screen.seqs(
    fasta=current,
    count=current,
    start=1044,
    end=43116,
    minlength=200
)

summary.seqs(
    fasta=current,
    count=current
)

###############################################################################
# 7. Filter Alignment Columns
###############################################################################
# Remove empty alignment columns
###############################################################################

filter.seqs(
    fasta=current,
    vertical=T,
    trump=.
)

unique.seqs(
    fasta=current,
    count=current
)

summary.seqs(
    fasta=current,
    count=current
)

###############################################################################
# 8. Chimera Detection with VSEARCH
###############################################################################
# VSEARCH version:
#   v2.28.1
#
# Output:
#   *.chimeras
#   *.accnos
###############################################################################

chimera.vsearch(
    fasta=current,
    count=current,
    dereplicate=t
)

# Optional chimera removal:
#
# remove.seqs(
#     fasta=current,
#     count=current,
#     accnos=current
# )

###############################################################################
# 9. Taxonomic Classification
###############################################################################
# Reference:
#   silva.nr_v138_1.align
#   silva.nr_v138_1.tax
###############################################################################

classify.seqs(
    fasta=current,
    count=current,
    reference=silva.nr_v138_1.align,
    taxonomy=silva.nr_v138_1.tax
)

###############################################################################
# 10. Remove Non-Bacterial Lineages
###############################################################################
# Remove:
#   chloroplast
#   mitochondria
#   archaea
#   eukaryota
#   unknown
###############################################################################

remove.lineage(
    fasta=current,
    count=current,
    taxonomy=current,
    taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota
)

summary.seqs(
    fasta=current,
    count=current
)

###############################################################################
# 11. Generate ASV Table
###############################################################################
# Output:
#   *.shared
#   *.asv.list
###############################################################################

make.shared(
    count=current
)

###############################################################################
# 12. Assign Taxonomy to ASVs
###############################################################################
# Output:
#   *.cons.taxonomy
#   *.tax.summary
###############################################################################

classify.otu(
    taxonomy=current,
    list=current,
    count=current
)

###############################################################################
# Pipeline Complete
###############################################################################