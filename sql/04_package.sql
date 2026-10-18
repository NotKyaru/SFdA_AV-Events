-- ============================================
-- 04 - Package pkg_facturacion
-- Público: lo que está en la especificación
-- Privado: lo que está solo en el cuerpo
-- ============================================

-- Especificación del Package
CREATE OR REPLACE PACKAGE pkg_facturacion IS
   PROCEDURE sp_proceso_mensual(p_mes IN NUMBER, p_anno IN NUMBER);
   PROCEDURE sp_generar_resumen(p_mes IN NUMBER, p_anno IN NUMBER);
   FUNCTION fn_ingresos_mes(p_mes IN NUMBER, p_anno IN NUMBER) RETURN NUMBER;
END pkg_facturacion;
/

-- Cuerpo del Package
CREATE OR REPLACE PACKAGE BODY pkg_facturacion IS

   -- Procedimiento Privado
   PROCEDURE print_line(p_texto IN VARCHAR2) IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE(p_texto);
   END print_line;

   -- Función Privada: clasificación del ingreso (mismo supuesto de la EP1)
   FUNCTION fn_clasificar(p_ingreso IN NUMBER) RETURN VARCHAR2 IS
   BEGIN
      IF p_ingreso >= 3000000 THEN
         RETURN 'ALTO';
      ELSIF p_ingreso >= 1000000 THEN
         RETURN 'MEDIO';
      ELSE
         RETURN 'BAJO';
      END IF;
   END fn_clasificar;

   -- Función Pública: total facturado en un mes
   -- EXTRACT no aparece en las guías: el script del caso lo usa con YEAR
   FUNCTION fn_ingresos_mes(p_mes IN NUMBER, p_anno IN NUMBER) RETURN NUMBER IS
      v_total NUMBER;
   BEGIN
      SELECT SUM(f.total_factura) INTO v_total
      FROM factura_arriendo f
      JOIN arriendo_equipo_av a ON f.id_arriendo = a.id_arriendo
      WHERE EXTRACT(MONTH FROM a.fecha_ini_arriendo) = p_mes
      AND EXTRACT(YEAR FROM a.fecha_ini_arriendo) = p_anno;
      RETURN v_total;
   END fn_ingresos_mes;

   -- Procedimiento Público: resumen por tipo de equipo
   PROCEDURE sp_generar_resumen(p_mes IN NUMBER, p_anno IN NUMBER) IS
      CURSOR c_tipos (p_m NUMBER, p_a NUMBER) IS
         SELECT e.id_tipo_equipo, t.nombre_tipo_equipo,
                COUNT(*) AS cantidad,
                SUM(f.dias_solicitados) AS dias,
                SUM(f.total_factura) AS ingreso
         FROM factura_arriendo f
         JOIN arriendo_equipo_av a ON f.id_arriendo = a.id_arriendo
         JOIN equipo_av e ON f.cod_equipo = e.cod_equipo
         JOIN tipo_equipo t ON e.id_tipo_equipo = t.id_tipo_equipo
         WHERE EXTRACT(MONTH FROM a.fecha_ini_arriendo) = p_m
         AND EXTRACT(YEAR FROM a.fecha_ini_arriendo) = p_a
         GROUP BY e.id_tipo_equipo, t.nombre_tipo_equipo;
      v_clasificacion resumen_arriendo_tipo.clasificacion%TYPE;
      v_existe        NUMBER;
   BEGIN
      print_line('Resumen por tipo de equipo ' || p_mes || '/' || p_anno);
      FOR r_tipo IN c_tipos(p_mes, p_anno) LOOP
         -- Se calcula una sola vez y se usa en el INSERT o UPDATE
         -- y en el mensaje de salida
         v_clasificacion := fn_clasificar(r_tipo.ingreso);

         SELECT COUNT(*) INTO v_existe
         FROM resumen_arriendo_tipo
         WHERE id_tipo_equipo = r_tipo.id_tipo_equipo
         AND mes_proceso = p_mes
         AND anno_proceso = p_anno;

         IF v_existe = 0 THEN
            INSERT INTO resumen_arriendo_tipo
            VALUES (r_tipo.id_tipo_equipo, p_mes, p_anno, r_tipo.nombre_tipo_equipo,
                    r_tipo.cantidad, r_tipo.dias, r_tipo.ingreso, v_clasificacion);
         ELSE
            UPDATE resumen_arriendo_tipo
            SET cantidad_arriendos = r_tipo.cantidad,
                total_dias         = r_tipo.dias,
                ingreso_total      = r_tipo.ingreso,
                clasificacion      = v_clasificacion
            WHERE id_tipo_equipo = r_tipo.id_tipo_equipo
            AND mes_proceso = p_mes
            AND anno_proceso = p_anno;
         END IF;

         print_line(r_tipo.nombre_tipo_equipo || ': ' || r_tipo.cantidad ||
                    ' arriendos, $' || r_tipo.ingreso || ' (' || v_clasificacion || ')');
      END LOOP;
   END sp_generar_resumen;

   -- Procedimiento Público: proceso completo del mes
   PROCEDURE sp_proceso_mensual(p_mes IN NUMBER, p_anno IN NUMBER) IS
   BEGIN
      print_line('=== Proceso mensual ' || p_mes || '/' || p_anno || ' ===');
      sp_generar_facturas(p_mes, p_anno);   -- procedimiento almacenado del archivo 03
      sp_generar_resumen(p_mes, p_anno);
      print_line('Total facturado del mes: $' || fn_ingresos_mes(p_mes, p_anno));
   END sp_proceso_mensual;

END pkg_facturacion;
/
