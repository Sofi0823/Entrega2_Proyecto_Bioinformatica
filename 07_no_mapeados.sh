#!/usr/bin/env bash
set -euo pipefail

IN_DIR="mapping"          
OUT_DIR="${IN_DIR}/unmapped"
mkdir -p "${OUT_DIR}"


echo ">>> Procesando evo1..."


samtools view -b -f 4 "${IN_DIR}/evo1.sorted.bam" > "${OUT_DIR}/evo1.unmapped.bam"

samtools fastq "${OUT_DIR}/evo1.unmapped.bam" \
    -1 "${OUT_DIR}/evo1_R1.unmapped.fastq.gz" \
    -2 "${OUT_DIR}/evo1_R2.unmapped.fastq.gz" \
    -0 /dev/null -s /dev/null -n

echo ">>> evo1 listo."

echo ">>> Procesando evo2..."

samtools view -b -f 4 "${IN_DIR}/evo2.sorted.bam" > "${OUT_DIR}/evo2.unmapped.bam"

samtools fastq "${OUT_DIR}/evo2.unmapped.bam" \
    -1 "${OUT_DIR}/evo2_R1.unmapped.fastq.gz" \
    -2 "${OUT_DIR}/evo2_R2.unmapped.fastq.gz" \
    -0 /dev/null -s /dev/null -n

echo ">>> evo2 listo."

echo ">>> Proceso terminado. Archivos en ${OUT_DIR}/"

gunzip "${OUT_DIR}/evo1_R1.unmapped.fastq.gz"
gunzip "${OUT_DIR}/evo1_R2.unmapped.fastq.gz"
gunzip "${OUT_DIR}/evo2_R1.unmapped.fastq.gz"
gunzip "${OUT_DIR}/evo2_R2.unmapped.fastq.gz"
