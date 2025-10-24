#!/usr/bin/env bash
# =========================================================
# 09_anotacion_variantes.sh
# Anotación de variantes en las líneas evolucionadas
# utilizando SnpEff
# =========================================================

set -e

# ===========================
# CONFIGURACIÓN
# ===========================
GENOME_NAME="mi_genoma_evo"                     # Nombre de la base de datos en snpEff.config
GENOME_FASTA="data/spades/scaffolds_trimmed.fasta"
GFF_FILE="annotation/prokka/anc_annotation.gff"    # Ruta a tu archivo GFF/GTF
OUTDIR="variants/snpeff"
SNPEFF_JAR="$HOME/micromamba/envs/bioinfo/share/snpeff-5.0-1/snpEff.jar"     # Ajusta esta ruta
THREADS=4

# Archivos VCF de entrada (filtrados)
EVO1_VCF="variants/evo1_filtered.vcf"
EVO2_VCF="variants/evo2_filtered.vcf"

mkdir -p "${OUTDIR}"

# ===========================
# 1. Verificación de archivos
# ===========================
echo ">>> Verificando archivos requeridos..."

if [ ! -f "${EVO1_VCF}" ] || [ ! -f "${EVO2_VCF}" ]; then
    echo "ERROR: No se encontraron los archivos VCF filtrados."
    echo "Asegúrate de haber corrido 08_llamado_variantes.sh."
    exit 1
fi

if [ ! -f "${GENOME_FASTA}" ] || [ ! -f "${GFF_FILE}" ]; then
    echo "ERROR: No se encontraron los archivos del genoma o anotación (.gff)."
    exit 1
fi

if [ ! -f "${SNPEFF_JAR}" ]; then
    echo "ERROR: No se encontró el archivo snpEff.jar en ${SNPEFF_JAR}"
    exit 1
fi

echo "Archivos verificados correctamente ✅"

# ===========================
# 2. Construcción de la base de datos snpEff
# ===========================
echo ">>> Preparando base de datos local para SnpEff..."

# Directorio donde están los datos de snpEff
SNPEFF_DATA_DIR=$(dirname "${SNPEFF_JAR}")/data

if [ ! -d "${SNPEFF_DATA_DIR}/${GENOME_NAME}" ]; then
    echo "Creando carpeta de base de datos en ${SNPEFF_DATA_DIR}/${GENOME_NAME} ..."
    mkdir -p "${SNPEFF_DATA_DIR}/${GENOME_NAME}"
    cp "${GENOME_FASTA}" "${SNPEFF_DATA_DIR}/${GENOME_NAME}/sequences.fa"
    cp "${GFF_FILE}" "${SNPEFF_DATA_DIR}/${GENOME_NAME}/genes.gff"
else
    echo "Base de datos ya existente. Se usará la existente."
fi

# Agregar entrada al archivo snpEff.config (si no existe)
CONFIG_FILE=$(dirname "${SNPEFF_JAR}")/snpEff.config
if ! grep -q "${GENOME_NAME}" "${CONFIG_FILE}"; then
    echo "${GENOME_NAME}.genome : Mi_genoma_evolucionado" >> "${CONFIG_FILE}"
    echo "Entrada agregada al archivo snpEff.config"
else
    echo "Entrada ${GENOME_NAME} ya existe en snpEff.config"
fi

echo ">>> Construyendo base de datos..."
java -Xmx8g -jar "${SNPEFF_JAR}" build -gff3 -v "${GENOME_NAME}"

echo "Base de datos snpEff construida correctamente ✅"

# ===========================
# 3. Anotación de variantes
# ===========================
echo ">>> Anotando variantes con snpEff..."

java -Xmx8g -jar "${SNPEFF_JAR}" ann -v -canon -no-upstream -no-downstream \
    -s "${OUTDIR}/evo1_summary.html" \
    "${GENOME_NAME}" "${EVO1_VCF}" > "${OUTDIR}/evo1_annotated.vcf"

java -Xmx8g -jar "${SNPEFF_JAR}" ann -v -canon -no-upstream -no-downstream \
    -s "${OUTDIR}/evo2_summary.html" \
    "${GENOME_NAME}" "${EVO2_VCF}" > "${OUTDIR}/evo2_annotated.vcf"

echo "Archivos anotados generados:"
echo "   - ${OUTDIR}/evo1_annotated.vcf"
echo "   - ${OUTDIR}/evo2_annotated.vcf"
echo "   - ${OUTDIR}/evo1_summary.html"
echo "   - ${OUTDIR}/evo2_summary.html"

# ===========================
# 4. Resumen final
# ===========================
echo ">>> Generando resumen..."

{
    echo "===== RESUMEN DE ANOTACIÓN DE VARIANTES ====="
    echo "Base de datos usada: ${GENOME_NAME}"
    echo "Archivo de referencia: ${GENOME_FASTA}"
    echo "Anotaciones:"
    echo "  - evo1_annotated.vcf"
    echo "  - evo2_annotated.vcf"
    echo "Reportes HTML:"
    echo "  - evo1_summary.html"
    echo "  - evo2_summary.html"
    echo "Fecha de ejecución: $(date)"
} > "${OUTDIR}/summary_annotation.txt"

echo "Resumen generado en ${OUTDIR}/summary_annotation.txt ✅"
echo "Proceso completo de anotación finalizado ✅"
