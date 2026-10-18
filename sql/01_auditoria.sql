-- ============================================
-- 01 - Tabla y secuencia de auditoría
-- La usa el trigger de sentencia (archivo 05)
-- ============================================

-- Borrar si ya existen (igual que el script del caso)
-- La primera vez muestra ORA-00942 / ORA-02289: es normal
DROP TABLE auditoria_factura;
DROP SEQUENCE seq_auditoria_factura;

-- Crear tabla de auditoría
CREATE TABLE auditoria_factura (
   id_auditoria    NUMBER PRIMARY KEY,
   operacion       VARCHAR2(10),
   fecha_operacion DATE
);

-- Crear secuencia para generar IDs únicos
CREATE SEQUENCE seq_auditoria_factura START WITH 1 INCREMENT BY 1;
