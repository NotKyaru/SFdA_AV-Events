-- ============================================
-- 02 - Funciones almacenadas
-- ============================================

-- Función sin parámetros: cantidad de facturas generadas
CREATE OR REPLACE FUNCTION fn_total_facturas RETURN NUMBER IS
   v_total NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_total FROM factura_arriendo;
   RETURN v_total;
END fn_total_facturas;
/

-- Función con parámetros: porcentaje de ajuste según el tipo de cliente
CREATE OR REPLACE FUNCTION fn_obtener_pct_ajuste(p_id_tipo_cli IN VARCHAR2) RETURN NUMBER IS
   v_pct ajuste_cliente.pct_ajuste%TYPE;
BEGIN
   SELECT pct_ajuste INTO v_pct
   FROM ajuste_cliente
   WHERE id_tipo_cli = p_id_tipo_cli;
   RETURN v_pct;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;   -- tipo de cliente sin ajuste: no se descuenta ni se recarga
END fn_obtener_pct_ajuste;
/

-- Función con parámetros: aplica el ajuste al monto
-- (porcentaje negativo = descuento, positivo = recargo)
CREATE OR REPLACE FUNCTION fn_aplicar_ajuste(p_monto IN NUMBER, p_pct IN NUMBER) RETURN NUMBER IS
BEGIN
   RETURN p_monto + (p_monto * p_pct / 100);
END fn_aplicar_ajuste;
/

-- Función con parámetros: IVA del 19%
-- (supuesto del equipo: el caso no indica la tasa)
CREATE OR REPLACE FUNCTION fn_calcular_iva(p_monto_neto IN NUMBER) RETURN NUMBER IS
BEGIN
   RETURN p_monto_neto * 19 / 100;
END fn_calcular_iva;
/
