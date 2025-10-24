#!/usr/bin/env bash
set -euxo pipefail

GENOME_FILE="data/spades/scaffolds_trimmed.fasta"
OUTDIR="annotation"

mkdir -p "${OUTDIR}"

run_busco(){
    CPU=8 #CAMBIAR SEGÚN NÚMERO DE NÚCLEOS DEL COMPUTADOR
    echo ">>> Ejecutando busco para el archivo ${GENOME_FILE}"
    busco \
        -i "${GENOME_FILE}" \
        -m genome \
        -l bacteria_odb12 \
        -o "${OUTDIR}/busco_results" \
        -c "${CPU}"\
        -f 
}
mv busco_downloads "${OUTDIR}"
run_busco
echo ">>> Ejecución terminada. Resultados disponibles en: ${OUTDIR}/busco_results/ como short_summary.* en formato de texto"