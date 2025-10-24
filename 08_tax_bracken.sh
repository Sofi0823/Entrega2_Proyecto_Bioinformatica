#!/usr/bin/env bash
set -euxo pipefail

KMER_FILE="minikraken2_database"
OUTDIR="taxonomy"
READ_LEN=150
mkdir -p "${OUTDIR}/bracken_results"

run_bracken_file() {
    REPORT=$1
    PREFIX=$2
    LEVEL=$3  # Nivel taxonómico: D, P, G, S
    THRESHOLD=5

    echo ">>> Ejecutando Bracken (archivo único) para ${PREFIX} (nivel ${LEVEL})..."
    bracken \
        -d "${KMER_FILE}" \
        -i "${REPORT}" \
        -l "${LEVEL}" \
        -r "${READ_LEN}"\
        -t "${THRESHOLD}" \
        -o "${OUTDIR}/bracken_results/${PREFIX}_${LEVEL}.bracken.txt"
    echo ">>> ${PREFIX} (${LEVEL}) listo."
}

# Ejecutar para los dos reportes
run_bracken_file "${OUTDIR}/evo1.report.txt" "evo1" "S"
run_bracken_file "${OUTDIR}/evo2.report.txt" "evo2" "S"

echo ">>> Bracken completado. Resultados disponibles en: ${OUTDIR}/bracken_results/"
