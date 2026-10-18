-- ============================================
-- 03 - Procedimientos almacenados
-- Usan las funciones del archivo 02
-- ============================================

-- Procedimiento con parámetros: genera las facturas de un mes y año
CREATE OR REPLACE PROCEDURE sp_generar_facturas(
   p_mes  IN NUMBER,
   p_anno IN NUMBER
) IS
   -- EXTRACT no aparece en las guías; lo usa el script del caso del profesor
   CURSOR c_arriendos (p_m NUMBER, p_a NUMBER) IS
      SELECT a.id_arriendo, a.cod_equipo, a.numrun_cli, c.id_tipo_cli,
             a.dias_solicitados, e.valor_arriendo_dia
      FROM arriendo_equipo_av a
      JOIN equipo_av e ON a.cod_equipo = e.cod_equipo
      JOIN cliente c ON a.numrun_cli = c.numrun_cli
      WHERE EXTRACT(MONTH FROM a.fecha_ini_arriendo) = p_m
      AND EXTRACT(YEAR FROM a.fecha_ini_arriendo) = p_a;

   v_id_arriendo  arriendo_equipo_av.id_arriendo%TYPE;
   v_cod_equipo   arriendo_equipo_av.cod_equipo%TYPE;
   v_numrun_cli   arriendo_equipo_av.numrun_cli%TYPE;
   v_id_tipo_cli  cliente.id_tipo_cli%TYPE;
   v_dias         arriendo_equipo_av.dias_solicitados%TYPE;
   v_valor_dia    equipo_av.valor_arriendo_dia%TYPE;
   v_monto_bruto  factura_arriendo.monto_bruto%TYPE;
   v_pct_ajuste   factura_arriendo.pct_ajuste%TYPE;
   v_monto_ajuste factura_arriendo.monto_ajuste%TYPE;
   v_tipo_ajuste  factura_arriendo.tipo_ajuste%TYPE;
   v_monto_neto   factura_arriendo.monto_neto%TYPE;
   v_iva          factura_arriendo.iva%TYPE;
   v_existe       NUMBER;
   v_cantidad     NUMBER := 0;
BEGIN
   OPEN c_arriendos(p_mes, p_anno);
   LOOP
      FETCH c_arriendos INTO v_id_arriendo, v_cod_equipo, v_numrun_cli,
                             v_id_tipo_cli, v_dias, v_valor_dia;
      EXIT WHEN c_arriendos%NOTFOUND;

      -- Revisar si el arriendo ya fue facturado
      SELECT COUNT(*) INTO v_existe
      FROM factura_arriendo
      WHERE id_arriendo = v_id_arriendo;

      IF v_existe = 0 THEN
         v_monto_bruto  := v_dias * v_valor_dia;
         v_pct_ajuste   := fn_obtener_pct_ajuste(v_id_tipo_cli);
         v_monto_neto   := fn_aplicar_ajuste(v_monto_bruto, v_pct_ajuste);
         v_monto_ajuste := v_monto_neto - v_monto_bruto;

         IF v_pct_ajuste < 0 THEN
            v_tipo_ajuste := 'DESCUENTO';
         ELSIF v_pct_ajuste > 0 THEN
            v_tipo_ajuste := 'RECARGO';
         ELSE
            v_tipo_ajuste := 'SIN AJUSTE';
         END IF;

         v_iva := fn_calcular_iva(v_monto_neto);

         INSERT INTO factura_arriendo
         VALUES (v_id_arriendo, v_cod_equipo, v_numrun_cli, v_id_tipo_cli, v_dias,
                 v_valor_dia, v_monto_bruto, v_pct_ajuste, v_monto_ajuste,
                 v_tipo_ajuste, v_monto_neto, v_iva, v_monto_neto + v_iva);
         v_cantidad := v_cantidad + 1;
      ELSE
         DBMS_OUTPUT.PUT_LINE('Arriendo ' || v_id_arriendo || ' ya estaba facturado');
      END IF;
   END LOOP;
   CLOSE c_arriendos;
   DBMS_OUTPUT.PUT_LINE('Facturas generadas: ' || v_cantidad);
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error al generar facturas: ' || SQLERRM);
END sp_generar_facturas;
/

-- Procedimiento sin parámetros: lista todas las facturas generadas
CREATE OR REPLACE PROCEDURE sp_reporte_facturas IS
BEGIN
   DBMS_OUTPUT.PUT_LINE('Reporte de facturas');
   FOR factura IN (SELECT f.id_arriendo, c.pnombre_cli, c.appaterno_cli,
                          f.tipo_ajuste, f.total_factura
                   FROM factura_arriendo f
                   JOIN cliente c ON f.numrun_cli = c.numrun_cli) LOOP
      DBMS_OUTPUT.PUT_LINE('Arriendo: ' || factura.id_arriendo || ', Cliente: ' ||
                           factura.pnombre_cli || ' ' || factura.appaterno_cli ||
                           ', ' || factura.tipo_ajuste || ', Total: ' || factura.total_factura);
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('Total de facturas: ' || fn_total_facturas);
END sp_reporte_facturas;
/
