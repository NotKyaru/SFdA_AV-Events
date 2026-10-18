-- ============================================
-- 05 - Triggers sobre FACTURA_ARRIENDO
-- ============================================

-- Trigger a nivel de fila: valida cada factura antes de guardarla
CREATE OR REPLACE TRIGGER trg_valida_factura
BEFORE INSERT ON factura_arriendo
FOR EACH ROW
BEGIN
   IF :NEW.dias_solicitados <= 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Los días solicitados deben ser mayores a cero');
   END IF;
   IF :NEW.total_factura <> :NEW.monto_neto + :NEW.iva THEN
      RAISE_APPLICATION_ERROR(-20002, 'El total no coincide con neto + IVA');
   END IF;
END;
/

-- Trigger a nivel de sentencia: registra cada operación sobre la tabla
CREATE OR REPLACE TRIGGER trg_auditoria_factura
AFTER INSERT OR UPDATE OR DELETE ON factura_arriendo
BEGIN
   IF INSERTING THEN
      INSERT INTO auditoria_factura (id_auditoria, operacion, fecha_operacion)
      VALUES (seq_auditoria_factura.NEXTVAL, 'INSERT', SYSDATE);
   ELSIF UPDATING THEN
      INSERT INTO auditoria_factura (id_auditoria, operacion, fecha_operacion)
      VALUES (seq_auditoria_factura.NEXTVAL, 'UPDATE', SYSDATE);
   ELSIF DELETING THEN
      INSERT INTO auditoria_factura (id_auditoria, operacion, fecha_operacion)
      VALUES (seq_auditoria_factura.NEXTVAL, 'DELETE', SYSDATE);
   END IF;
END;
/
