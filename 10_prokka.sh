#!/usr/bin/env bash
set -euxo pipefail

GENOME_FILE="data/spades/scaffolds_trimmed.fasta"
OUTDIR="annotation/prokka"
mkdir -p "${OUTDIR}"

PREFIX="anc_annotation" # Prefijo para los archivos de salida
LOCUSTAG="ECPOOp"   # Identificador base para los genes
CPU=8   # Número de núcleos de CPU


echo ">>> Ejecutando PROKKA para el genoma bacteriano de Escherichia coli..."
prokka \
    --outdir "${OUTDIR}" \
    --force \
    --prefix "${PREFIX}" \
    --addgenes \
    --locustag "${LOCUSTAG}" \
    --increment 1 \
    --gffver 2 \
    --compliant \
    --genus "Escherichia" \
    --species "coli" \
    --kingdom "Bacteria" \
    --gcode 11 \
    --usegenus \
    --evalue 1e-9 \
    --rfam \
    --cpus "${CPU}" \
    "${GENOME_FILE}"         


echo ">>> Anotación completada correctamente."
echo ">>> Resultados disponibles en: ${OUTDIR}/"
echo ">>> Archivos principales:"
echo "    - ${PREFIX}.gff   → anotaciones completas"
echo "    - ${PREFIX}.gbk   → formato GenBank"
echo "    - ${PREFIX}.faa   → proteínas predichas"
echo "    - ${PREFIX}.ffn   → secuencias génicas (nucleótidos)"
echo "    - ${PREFIX}.txt   → resumen de anotación"
