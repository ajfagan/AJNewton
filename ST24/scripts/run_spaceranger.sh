#!/bin/bash

PROJECT_DIR=./condor_files

SPACERANGER_DIR=${PROJECT_DIR}/spaceranger-3.1.1

TIFF_DIR=${PROJECT_DIR}/HE_slides

TRANSCRIPTOME_DIR=${PROJECT_DIR}/ref 
HUMAN_TRANSCRIPTOME_DIR=${TRANSCRIPTOME_DIR}/refdata-gex-GRCh38-2020-A
#MACAQUES_TRANSCRIPTOME_DIR=${TRANSCRIPTOME_DIR}/

FASTQ_DIR=${PROJECT_DIR}/fastqs

NUM_CORES=16
CREATE_BAM=false 

# Set 1
## Rhesus macaques
#samples=("Mky-2544" "Mky-194-8" "Hu-A6" "Mky-194-10")
#areas=("A" "B" "C" "D");
#for sample in 1 2 4; do
#  ../spaceranger-3.1.1/bin/spaceranger count \
#      --id ${samples[((sample-1))]} \
#      --image ../HE_slides/set_1/V10D07-403-A${sample}.tif \
#      --slide V10D07-403 \
#      --area "${areas[((sample-1))]}1" \
#      --transcriptome ../ref/Macaca_mulatta.Mmul_10.dna.toplevel.fa \	# Use macaques transcriptome
#      --transcriptome ../ref/refdata-gex-GRCh38-2020-A \ 		# Use human transcriptome
#      --fastqs ../data/fastqs/${samples[((sample-1))]} \
#      --create-bam false \
#      --localcores 16
#done

# Set 2 --- slide 1 
## Rhesus macaques
samples=(MP2 MP7 MP19 MP33)
areas=("A" "B" "C" "D");
for sample in 1 2 3 4; do
  ${SPACERANGER_DIR}/bin/spaceranger count \
      --id ${samples[((sample-1))]} \
      --image ${TIFF_DIR}/set_2/V13F13-338-A${sample}.tif \
      --slide V13F13-338 \
      --area "${areas[((sample-1))]}1" \
#      --transcriptome ${MACAQUES_TRANSCRIPTOME_DIR} \	# Use macaques transcriptome
      --transcriptome ${HUMAN_TRANSCRIPTOME_DIR} \ 	# Use human transcriptome
      --fastqs ${FASTQ_DIR}/${samples[((sample-1))]} \
      --create-bam CREATE_BAM \
      --localcores NUM_CORES
done

# Set 2 --- slide 2 
## Human
samples=(MP31 MPH1 MPH2 MP37)
areas=("A" "B" "C" "D");
for sample in 2 3; do
  ${SPACERANGER_DIR}/bin/spaceranger count \
      --id ${samples[((sample-1))]} \
      --image ${TIFF_DIR}/set_2/V13F13-339-A${sample}.tif \
      --slide V13F13-339 \
      --area "${areas[((sample-1))]}1" \
      --transcriptome ${HUMAN_TRANSCRIPTOME_DIR} \ 	# Use human transcriptome
      --fastqs ${FASTQ_DIR}/${samples[((sample-1))]} \
      --create-bam CREATE_BAM \
      --localcores NUM_CORES
done
## Rhesus macaques 
samples=(MP31 MPH1 MPH2 MP37)
areas=("A" "B" "C" "D");
for sample in 1 4; do
  ${SPACERANGER_DIR}/bin/spaceranger count \
      --id ${samples[((sample-1))]} \
      --image ${TIFF_DIR}/set_2/V13F13-339-A${sample}.tif \
      --slide V13F13-339 \
      --area "${areas[((sample-1))]}1" \
#      --transcriptome ${MACAQUES_TRANSCRIPTOME_DIR} \	# Use macaques transcriptome
      --transcriptome ${HUMAN_TRANSCRIPTOME_DIR} \	# Use human transcriptome
      --fastqs ${FASTQ_DIR}/${samples[((sample-1))]} \
      --create-bam CREATE_BAM \
      --localcores NUM_CORES
done

