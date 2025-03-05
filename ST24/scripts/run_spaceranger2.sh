#!/bin/bash

PROJECT_DIR=.

SPACERANGER_DIR=${PROJECT_DIR}/spaceranger-3.1.1

TIFF_DIR=${PROJECT_DIR}/HE_slides

TRANSCRIPTOME_DIR=${PROJECT_DIR}/ref 
HUMAN_TRANSCRIPTOME_DIR=${TRANSCRIPTOME_DIR}/refdata-gex-GRCh38-2020-A
#MACAQUES_TRANSCRIPTOME_DIR=${TRANSCRIPTOME_DIR}/

FASTQ_DIR=${PROJECT_DIR}/fastqs

NUM_CORES=16
CREATE_BAM=false 

areas=("A" "B" "C" "D");

${SPACERANGER_DIR}/bin/spaceranger count \
  --id $1 \
  --image ${TIFF_DIR}/$2/$3-A$4 \
  --slide $3 \
  --area "${areas[(($4-1))]}1" \
  --transcriptome "${TRANSCRIPTOME_DIR}/$5" \
  --fastqs ${FASTQ_DIR}/$1 \
  --create-bam CREATE_BAM \
  --localcores NUM_CORES
