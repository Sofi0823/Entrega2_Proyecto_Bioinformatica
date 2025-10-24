#!/usr/bin/env bash
set -euo pipefail

DBNAME="minikraken2_database"     # Carpeta donde está la base de datos de Kraken2
THREADS=8
OUTDIR="taxonomy"
mkdir -p "${OUTDIR}"

GEN1_R1="mapping/unmapped/evo1_R1.unmapped.fastq"
GEN1_R2="mapping/unmapped/evo1_R2.unmapped.fastq"

GEN2_R1="mapping/unmapped/evo2_R1.unmapped.fastq"
GEN2_R2="mapping/unmapped/evo2_R2.unmapped.fastq"

clasificar_genoma() {
    R1=$1
    R2=$2
    PREFIX=$3

    echo ">>> Clasificando ${PREFIX} con Kraken2..."
    kraken2 \
        --db "${DBNAME}" \
        --threads "${THREADS}" \
        --paired \
        --report "${OUTDIR}/${PREFIX}.report.txt" \
        --output "${OUTDIR}/${PREFIX}.kraken.txt" \
        --classified-out "${OUTDIR}/${PREFIX}.classified#.fq" \
        --unclassified-out "${OUTDIR}/${PREFIX}.unclassified#.fq" \
        "${R1}" "${R2}"

    echo ">>> ${PREFIX} listo."
}

clasificar_genoma "${GEN1_R1}" "${GEN1_R2}" "evo1"
clasificar_genoma "${GEN2_R1}" "${GEN2_R2}" "evo2"

echo ">>> Clasificación completada. Resultados en ${OUTDIR}/"
