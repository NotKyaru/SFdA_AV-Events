-- ============================================
-- Pruebas EP2 - ejecutar con F5 después de sql/06_demo.sql
-- Cada prueba imprime OK o FAIL
-- ============================================

-- Comando de SQL Developer para ver los DBMS_OUTPUT (no aparece en las guías)
SET SERVEROUTPUT ON;

-- Pruebas 1 a 4: funciones
DECLARE
   v_resultado NUMBER;
BEGIN
   v_resultado := fn_obtener_pct_ajuste('S');
   IF v_resultado = -15 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 1: cliente socio tiene -15%');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 1: se esperaba -15 y llegó ' || v_resultado);
   END IF;

   v_resultado := fn_obtener_pct_ajuste('X');
   IF v_resultado = 0 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 2: tipo inexistente devuelve 0 (NO_DATA_FOUND)');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 2: se esperaba 0 y llegó ' || v_resultado);
   END IF;

   v_resultado := fn_aplicar_ajuste(360000, -15);
   IF v_resultado = 306000 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 3: 360000 con -15% da 306000');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 3: se esperaba 306000 y llegó ' || v_resultado);
   END IF;

   v_resultado := fn_calcular_iva(306000);
   IF v_resultado = 58140 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 4: IVA de 306000 es 58140');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 4: se esperaba 58140 y llegó ' || v_resultado);
   END IF;
END;
/

-- Pruebas 5 y 6: procedimiento con parámetros
DECLARE
   v_antes   NUMBER;
   v_despues NUMBER;
BEGIN
   v_antes := fn_total_facturas;
   IF v_antes = 23 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 5: hay 23 facturas de marzo');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 5: se esperaban 23 facturas y hay ' || v_antes);
   END IF;

   -- Correrlo otra vez no debe duplicar facturas
   sp_generar_facturas(3, 2026);
   v_despues := fn_total_facturas;
   IF v_despues = v_antes THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 6: segunda ejecución no duplica facturas');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 6: antes ' || v_antes || ', después ' || v_despues);
   END IF;
END;
/

-- Pruebas 7 y 8: package (función pública y resumen)
DECLARE
   v_total         NUMBER;
   v_clasificacion resumen_arriendo_tipo.clasificacion%TYPE;
BEGIN
   v_total := pkg_facturacion.fn_ingresos_mes(3, 2026);
   IF v_total = 19236469 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 7: total facturado de marzo es 19236469');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 7: se esperaba 19236469 y llegó ' || v_total);
   END IF;

   SELECT clasificacion INTO v_clasificacion
   FROM resumen_arriendo_tipo
   WHERE id_tipo_equipo = 'L' AND mes_proceso = 3 AND anno_proceso = 2026;
   IF v_clasificacion = 'ALTO' THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 8: Pantalla LED quedó clasificada ALTO');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 8: se esperaba ALTO y llegó ' || v_clasificacion);
   END IF;

   SELECT clasificacion INTO v_clasificacion
   FROM resumen_arriendo_tipo
   WHERE id_tipo_equipo = 'P' AND mes_proceso = 3 AND anno_proceso = 2026;
   IF v_clasificacion = 'MEDIO' THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 8: Proyector quedó clasificado MEDIO');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 8: se esperaba MEDIO y llegó ' || v_clasificacion);
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 8: no existe el resumen de marzo');
END;
/

-- Prueba 9: trigger de fila rechaza un total que no cuadra
BEGIN
   INSERT INTO factura_arriendo
   VALUES (9999, 'AV001', 14250000, 'S', 2, 120000, 240000, -15, -36000,
           'DESCUENTO', 204000, 38760, 1);
   DBMS_OUTPUT.PUT_LINE('FAIL Prueba 9: el trigger dejó pasar la factura');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 9: trigger rechazó la factura -> ' || SQLERRM);
END;
/

-- Prueba 10: trigger de fila rechaza días en cero
BEGIN
   INSERT INTO factura_arriendo
   VALUES (9998, 'AV001', 14250000, 'S', 0, 120000, 0, -15, 0,
           'DESCUENTO', 0, 0, 0);
   DBMS_OUTPUT.PUT_LINE('FAIL Prueba 10: el trigger dejó pasar la factura');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 10: trigger rechazó la factura -> ' || SQLERRM);
END;
/

-- Prueba 11: trigger de sentencia registra UNA línea por un DELETE de 23 filas
-- (DELETE FROM no aparece en las guías; es SQL básico)
DECLARE
   v_antes    NUMBER;
   v_despues  NUMBER;
   v_borradas NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_antes FROM auditoria_factura;
   DELETE FROM factura_arriendo;
   v_borradas := SQL%ROWCOUNT;   -- filas borradas por el DELETE
   SELECT COUNT(*) INTO v_despues FROM auditoria_factura;
   IF v_despues = v_antes + 1 THEN
      DBMS_OUTPUT.PUT_LINE('OK   Prueba 11: DELETE de ' || v_borradas ||
                           ' filas dejó 1 sola línea de auditoría');
   ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL Prueba 11: la auditoría aumentó en ' || (v_despues - v_antes));
   END IF;

   -- Dejar las facturas como estaban
   pkg_facturacion.sp_proceso_mensual(3, 2026);
END;
/

-- Guardar los cambios (COMMIT no aparece en las guías; lo usa el script del caso)
COMMIT;

-- Prueba 12 (manual): una parte privada NO se puede llamar desde fuera.
-- Quitar los guiones de las 4 líneas siguientes y ejecutar.
-- Resultado esperado: error PLS-00302 (el componente FN_CLASIFICAR debe ser declarado)
-- BEGIN
--    DBMS_OUTPUT.PUT_LINE(pkg_facturacion.fn_clasificar(5000000));
-- END;
-- /
