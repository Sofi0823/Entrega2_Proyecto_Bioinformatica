#!/usr/bin/env bash
set -euxo pipefail

KRAKEN2_DIR="taxonomy"
KRONA_OUTDIR="taxonomy/krona_results"
mkdir -p "${KRONA_OUTDIR}"

cat taxonomy/evo1.report.txt | cut -f2,3 | ktImportTaxonomy taxonomy/evo1.report.txt -o taxonomy/krona_results/evo1_krona.html
cat taxonomy/evo2.report.txt | cut -f2,3 | ktImportTaxonomy taxonomy/evo2.report.txt -o taxonomy/krona_results/evo2_krona.html

echo ">>> Análisis Krona completado. Archivos disponibles en: ${KRONA_OUTDIR}/"
