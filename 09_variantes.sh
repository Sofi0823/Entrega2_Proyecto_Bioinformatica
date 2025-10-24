#!/usr/bin/env bash
# ===============================================
# 08_llamado_variantes.sh
# Llamado y filtrado de variantes en las líneas evolucionadas
# ===============================================

set -e

# ===========================
# CONFIGURACIÓN
# ===========================
GENOMA="data/spades/scaffolds_trimmed.fasta"
OUT="variants"
THREADS=4

# Archivos BAM alineados
EVO1_BAM="mapping/evo1.sorted.bam"
EVO2_BAM="mapping/evo2.sorted.bam"

mkdir -p "${OUT}"

# ===========================
# 1. Verificación de archivos
# ===========================
echo ">>> Verificando archivos requeridos..."

if [ ! -f "${GENOMA}" ]; then
  echo "ERROR: No se encontró el genoma ${GENOMA}"
  exit 1
fi

if [ ! -f "${EVO1_BAM}" ] || [ ! -f "${EVO2_BAM}" ]; then
  echo "ERROR: Archivos BAM no encontrados. Asegúrate de correr 07_mapeo.sh antes."
  exit 1
fi

echo "Archivos de entrada verificados."

# ===========================
# 2. Indexar genoma de referencia
# ===========================
echo ">>> Indexando genoma..."
samtools faidx "${GENOMA}"

# ===========================
# 3. Llamado de variantes con bcftools
# ===========================
echo ">>> Llamando variantes con bcftools..."

bcftools mpileup -Ou -f "${GENOMA}" "${EVO1_BAM}" | bcftools call -mv -Ov -o "${OUT}/evo1_raw.vcf"
bcftools mpileup -Ou -f "${GENOMA}" "${EVO2_BAM}" | bcftools call -mv -Ov -o "${OUT}/evo2_raw.vcf"

echo "Archivos VCF generados:"
echo "   - ${OUT}/evo1_raw.vcf"
echo "   - ${OUT}/evo2_raw.vcf"

# ===========================
# 4. Filtrado de variantes
# ===========================
echo ">>> Filtrando variantes con bcftools..."

bcftools filter -i 'QUAL>20 && DP>10' "${OUT}/evo1_raw.vcf" -o "${OUT}/evo1_filtered.vcf"
bcftools filter -i 'QUAL>20 && DP>10' "${OUT}/evo2_raw.vcf" -o "${OUT}/evo2_filtered.vcf"

echo "VCF filtrados:"
echo "   - ${OUT}/evo1_filtered.vcf"
echo "   - ${OUT}/evo2_filtered.vcf"

# ===========================
# 4.1 Comprimir e indexar para RTG
# ===========================
echo ">>> Comprimiendo e indexando VCF para RTG-tools..."

bgzip -c "${OUT}/evo1_filtered.vcf" > "${OUT}/evo1_filtered.vcf.gz"
bgzip -c "${OUT}/evo2_filtered.vcf" > "${OUT}/evo2_filtered.vcf.gz"

tabix -p vcf "${OUT}/evo1_filtered.vcf.gz"
tabix -p vcf "${OUT}/evo2_filtered.vcf.gz"

echo "   ✔ Archivos comprimidos:"
echo "     - evo1_filtered.vcf.gz"
echo "     - evo2_filtered.vcf.gz"

# ===========================
# 5. Estadísticas con vcflib
# ===========================
echo ">>> Calculando estadísticas con vcflib..."

vcfstats "${OUT}/evo1_filtered.vcf" > "${OUT}/evo1_vcflib_stats.txt"
vcfstats "${OUT}/evo2_filtered.vcf" > "${OUT}/evo2_vcflib_stats.txt"

vcfintersect --exact -i "${OUT}/evo1_filtered.vcf" "${OUT}/evo2_filtered.vcf" > "${OUT}/shared_variants.vcf"

echo "Estadísticas vcflib generadas:"
echo "   - evo1_vcflib_stats.txt"
echo "   - evo2_vcflib_stats.txt"
echo "   - shared_variants.vcf"

# ===========================
# 6. Comparación con RTG-tools
# ===========================
echo ">>> Comparando variantes con RTG-tools..."

if [ ! -d "${OUT}/rtg_ref" ]; then
    rtg format -o "${OUT}/rtg_ref" "${GENOMA}"
fi

rtg vcfeval \
  -b "${OUT}/evo1_filtered.vcf.gz" \
  -c "${OUT}/evo2_filtered.vcf.gz" \
  -t "${OUT}/rtg_ref" \
  -o "${OUT}/rtg_comparison" \
  --threads "${THREADS}"

echo "Resultados RTG en:"
echo "   - ${OUT}/rtg_comparison/"

# ===========================
# 7. Resumen final
# ===========================
echo ">>> Generando resumen..."

{
    echo "===== RESUMEN DEL LLAMADO DE VARIANTES ====="
    echo "Archivo de referencia: ${GENOMA}"
    echo "Variantes evo1: $(grep -vc '^#' ${OUT}/evo1_filtered.vcf)"
    echo "Variantes evo2: $(grep -vc '^#' ${OUT}/evo2_filtered.vcf)"
    echo "Variantes compartidas: $(grep -vc '^#' ${OUT}/shared_variants.vcf)"
} > "${OUT}/summary_variants.txt"

echo "Resumen generado en summary_variants.txt ✅"
echo "Proceso completo ✅"
