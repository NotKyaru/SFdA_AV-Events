-- ============================================
-- Limpieza para volver a ensayar la demo desde cero
-- (DELETE FROM no aparece en las guías; es SQL básico)
-- (COMMIT no aparece en las guías; lo usa el script del caso)
-- ============================================

DELETE FROM factura_arriendo;
DELETE FROM resumen_arriendo_tipo;
DELETE FROM auditoria_factura;
COMMIT;
