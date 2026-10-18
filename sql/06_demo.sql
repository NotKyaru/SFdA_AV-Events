-- ============================================
-- 06 - Demostración para la presentación
-- Ejecutar por partes: seleccionar el bloque y presionar F5
-- 2026 = año en que se cargó el script del caso
-- ============================================

-- Comando de SQL Developer para ver los DBMS_OUTPUT (no aparece en las guías)
SET SERVEROUTPUT ON;

-- 1) Función sin parámetros usada en SQL (antes del proceso da 0)
SELECT fn_total_facturas FROM dual;

-- 2) Funciones con parámetros usadas en SQL sobre todos los arriendos
SELECT a.id_arriendo, c.id_tipo_cli,
       a.dias_solicitados * e.valor_arriendo_dia AS monto_bruto,
       fn_obtener_pct_ajuste(c.id_tipo_cli) AS pct_ajuste,
       fn_aplicar_ajuste(a.dias_solicitados * e.valor_arriendo_dia,
                         fn_obtener_pct_ajuste(c.id_tipo_cli)) AS monto_neto
FROM arriendo_equipo_av a
JOIN equipo_av e ON a.cod_equipo = e.cod_equipo
JOIN cliente c ON a.numrun_cli = c.numrun_cli;

-- 3) Proceso mensual completo desde el package
BEGIN
   pkg_facturacion.sp_proceso_mensual(3, 2026);
END;
/

-- Guardar los cambios (COMMIT no aparece en las guías; lo usa el script del caso)
COMMIT;

-- 4) Procedimiento sin parámetros
BEGIN
   sp_reporte_facturas;
END;
/

-- 5) Resultados
SELECT fn_total_facturas FROM dual;
SELECT pkg_facturacion.fn_ingresos_mes(3, 2026) FROM dual;
SELECT * FROM factura_arriendo;
SELECT * FROM resumen_arriendo_tipo;
SELECT * FROM auditoria_factura;

-- 6) Trigger de sentencia: un solo DELETE borra 23 filas,
--    pero en la auditoría aparece una sola línea nueva
--    (DELETE FROM no aparece en las guías; es SQL básico)
DELETE FROM factura_arriendo;
SELECT * FROM auditoria_factura;

-- 7) Volver a generar las facturas para dejar la base lista
BEGIN
   pkg_facturacion.sp_proceso_mensual(3, 2026);
END;
/
COMMIT;
