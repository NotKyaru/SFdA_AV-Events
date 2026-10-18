# Guion literal - Presentación EP2 · AV EVENTS

**BDY1103 Taller de Base de Datos · Evaluación Parcial N° 2**
Integrantes: Gustavo Giha · Javier Jorquera · Martín Narváez
Docente: Marco Antonio Japke Adriasola

> **Cómo leer este guion**
> - **Decir:** el texto entre comillas se dice tal cual, palabra por palabra.
> - **Pantalla:** qué mostrar (diapositiva o SQL Developer).
> - **Abrir:** archivo y líneas a señalar. Para saltar a una línea en SQL Developer: **Ctrl+G** y escribir el número.
> - **Cómo funciona:** explicación corta para que ustedes lo entiendan. **No se lee en voz alta**; sirve para responder si el profesor pregunta.
> - **Ejecutar:** **Ctrl+Enter** para un `SELECT` o una sentencia suelta (se ve como tabla). Para un bloque `BEGIN … END; /` seleccionar las líneas y presionar **F5**.
> - **Deberían ver:** lo que aparece si todo salió bien.
>
> Durante las diapositivas 5 a 8 **solo se muestra el código** (no se ejecuta). Todo se ejecuta junto en la **Parte 4: Demostración final**.

---

## 0. Antes de presentar

1. En SQL Developer ejecutar con F5, en este orden:
   `BD_arriendo_equipos_AV_EVENTS.sql` → `sql/01_auditoria.sql` → `02` → `03` → `04` → `05`.
   **Ojo:** si vuelven a ejecutar el script del caso, este borra `FACTURA_ARRIENDO` (`DROP TABLE … CASCADE CONSTRAINTS`) y con ella se borran los triggers. Después hay que ejecutar otra vez `01` a `05`.
2. Revisar que todo quedó **VALID**:
   ```sql
   SELECT object_name, object_type, status FROM user_objects
   WHERE object_type IN ('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY','TRIGGER');
   ```
3. Ejecutar `pruebas/limpieza.sql` (F5) para partir con las tablas vacías.
4. Dejar abiertas estas pestañas, en este orden: `02_funciones.sql`, `03_procedimientos.sql`, `04_package.sql`, `05_triggers.sql`, `06_demo.sql`, `pruebas/pruebas_ep2.sql`.
5. Activar los números de línea: clic derecho en el margen izquierdo del editor → **Toggle Line Numbers** (o la opción equivalente si SQL Developer está en español).
6. En `06_demo.sql`, poner el cursor en la línea 8 (`SET SERVEROUTPUT ON;`) y presionar F5, para que los mensajes aparezcan en el Script Output.
7. En `pruebas/pruebas_ep2.sql`, seleccionar las líneas 154 a 157 y presionar **Ctrl+/** para quitarles los guiones (o borrar los `-- ` a mano). **No guardar** el archivo. Así el paso 6 de la demostración solo es seleccionar y F5.
8. Subir el tamaño de letra del editor para que se lea desde atrás (Tools → Preferences → Code Editor → Fonts; en español: Herramientas → Preferencias → Editor de código → Fuentes).
9. Tener la presentación y SQL Developer abiertos a la vez y cambiar entre ellos con **Alt+Tab**.
10. Ensayar con cronómetro: **máximo 15 minutos, la meta es 13** para tener margen. Cada uno debe poder explicar **cualquier** archivo, no solo el suyo.

---

## 1. Reparto y tiempos

| Parte | Quién | Diapositivas | Código que muestra | Tiempo |
|---|---|---|---|---|
| 1 | Javier Jorquera | 1 a 5 | `sql/02_funciones.sql` | 3:30 |
| 2 | Gustavo Giha | 6 | `sql/03_procedimientos.sql` | 2:30 |
| 3 | Martín Narváez | 7 a 10 | `sql/04_package.sql`, `sql/05_triggers.sql` | 3:30 |
| 4 | Los tres (cada uno ejecuta lo suyo) | — (SQL Developer) | `sql/06_demo.sql`, `pruebas/pruebas_ep2.sql` | 3:00 |
| 5 | Los tres | 11 y 12 | — | 0:30 |
| | | | **Total** | **13:00** |

El que habla maneja el teclado. En la Parte 4 cada uno ejecuta la parte de su tema.

**Control del tiempo:** si al terminar la Parte 2 ya pasaron más de 6 minutos, en la Parte 3 saltarse la diapositiva 9 y decir solo la última frase de la diapositiva 10.

---

## Parte 1 · Javier Jorquera (3:30)

### Diapositiva 1 · Portada

**Decir:**
"Buenas tardes, profesor. Somos Gustavo Giha, Martín Narváez y yo, Javier Jorquera. Les vamos a presentar el sistema de facturación de arriendos de AV EVENTS, hecho en PL/SQL con procedimientos, funciones, un package y triggers."

### Diapositiva 2 · Reparto

**Decir:**
"Yo explico el problema y las funciones; Gustavo, los procedimientos; y Martín, el package y los triggers. Al final mostramos todo funcionando en SQL Developer."

### Diapositiva 3 · El problema

**Decir:**
"AV EVENTS arrienda equipos audiovisuales. Cada arriendo queda en la tabla ARRIENDO_EQUIPO_AV, pero nadie calcula cuánto cobrar. Para cobrar hay que multiplicar los días por el valor diario, aplicar el ajuste del tipo de cliente, que va desde un 15 por ciento de descuento para el socio hasta un 8 por ciento de recargo para el extranjero, y sumar el IVA del 19 por ciento, que es un supuesto nuestro porque el caso no da la tasa. De los 103 arriendos, 23 son de marzo, y esos son los que facturamos."

### Diapositiva 4 · Cómo se conecta todo

**Pantalla:** señalar las cajas de arriba hacia abajo mientras se habla.

**Decir:**
"Todo parte con una sola llamada al package. El package llama al procedimiento que recorre los arriendos del mes; el procedimiento usa nuestras funciones para calcular el ajuste y el IVA; y cada factura que se inserta dispara los triggers, que validan y auditan. El resultado son 23 facturas por diecinueve millones doscientos treinta y seis mil cuatrocientos sesenta y nueve pesos."

### Diapositiva 5 · Funciones

**Decir:**
"Una función hace un cálculo y siempre devuelve un valor con RETURN; por eso se puede usar dentro de un SELECT y dentro de otros programas PL/SQL. Hicimos cuatro."

**Pantalla:** Alt+Tab a SQL Developer, pestaña `02_funciones.sql`.

**Abrir:** `sql/02_funciones.sql`, **líneas 6 a 11**.

**Decir:**
"fn_total_facturas, en la línea 6, no tiene parámetros. En la línea 9 cuenta las facturas con COUNT, y en la línea 10 devuelve el número."

**Cómo funciona:** `SELECT COUNT(*) INTO v_total` guarda la cantidad de filas en la variable y `RETURN` la entrega. Se llama sin paréntesis: `fn_total_facturas`.

**Abrir:** `sql/02_funciones.sql`, **líneas 15 a 25**.

**Decir:**
"fn_obtener_pct_ajuste, en la línea 15, recibe el tipo de cliente y busca su porcentaje en AJUSTE_CLIENTE. Si el tipo no existe, en la línea 23 se captura NO_DATA_FOUND y devuelve cero; así un dato raro no detiene el proceso."

**Cómo funciona:** un `SELECT … INTO` que no encuentra filas lanza `NO_DATA_FOUND`; la sección `EXCEPTION` lo atrapa y devuelve 0 (sin ajuste). La variable usa `%TYPE` (línea 16) para tener el mismo tipo que la columna.

**Abrir:** `sql/02_funciones.sql`, **línea 32** y después **línea 40**.

**Decir:**
"Las otras dos son cálculos de una línea. En la línea 32, fn_aplicar_ajuste le suma al monto su porcentaje; como el descuento está guardado en negativo, la misma fórmula descuenta o recarga. Y en la línea 40, fn_calcular_iva saca el 19 por ciento. Gustavo, te dejo con los procedimientos."

**Cómo funciona:** 360.000 + (360.000 × −15 / 100) = 306.000. IVA: 306.000 × 19 / 100 = 58.140. Si cambia el IVA, se cambia solo la línea 40.

**Pantalla:** Alt+Tab a la presentación, diapositiva 6.

---

## Parte 2 · Gustavo Giha (2:30)

### Diapositiva 6 · Procedimientos

**Decir:**
"Gracias. Un procedimiento no está obligado a devolver un valor: ejecuta una tarea. Hicimos uno con parámetros, que genera las facturas de un mes, y otro sin parámetros, que las lista."

**Pantalla:** Alt+Tab a SQL Developer, pestaña `03_procedimientos.sql`.

**Abrir:** `sql/03_procedimientos.sql`, **líneas 7 a 19**.

**Decir:**
"sp_generar_facturas recibe el mes y el año en las líneas 8 y 9. En la línea 12 declara un cursor con parámetros que une el arriendo, el equipo y el cliente, y en las líneas 18 y 19 filtra por mes y año con EXTRACT, que no está en las guías, pero lo usa el script del caso."

**Cómo funciona:** los parámetros `IN` solo entran al procedimiento. Los `JOIN … ON` traen el valor diario (equipo) y el tipo de cliente (cliente). `EXTRACT(MONTH FROM fecha)` da 3 para marzo.

**Abrir:** `sql/03_procedimientos.sql`, **líneas 36 a 47**.

**Decir:**
"En la línea 36 abre el cursor, y el LOOP trae un arriendo a la vez con FETCH, hasta que %NOTFOUND indica que no quedan. Para cada uno, en la línea 43, cuenta si ya tiene factura; así, si se ejecuta dos veces, no duplica nada."

**Cómo funciona:** es el patrón `OPEN` / `FETCH` / `EXIT WHEN %NOTFOUND` / `CLOSE` de la unidad 1. Si el arriendo ya está facturado, `COUNT(*)` da 1 y se va al `ELSE` de la línea 68, que solo muestra un mensaje.

**Abrir:** `sql/03_procedimientos.sql`, **líneas 48 a 66**.

**Decir:**
"Si no tiene, calcula el bruto en la línea 48 y usa las funciones de Javier: el ajuste en las líneas 49 y 50, y el IVA en la 61. Con IF y ELSIF, en la línea 53, decide si es descuento, recargo o sin ajuste. Y en la línea 63 inserta la factura."

**Cómo funciona:** porcentaje negativo → DESCUENTO, positivo → RECARGO, cero → SIN AJUSTE. El total (final de la línea 66) es neto + IVA. Cada `INSERT` dispara los triggers del archivo 05.

**Abrir:** `sql/03_procedimientos.sql`, **línea 75**, y después **líneas 81 a 92**.

**Decir:**
"Si algo falla, WHEN OTHERS, en la línea 75, muestra el error con SQLERRM. Y sp_reporte_facturas, en la línea 81, no tiene parámetros: recorre las facturas con un FOR y al final, en la línea 92, muestra el total usando la función sin parámetros de Javier. Martín."

**Cómo funciona:** `SQLERRM` tiene el texto del error de Oracle. El `FOR … IN (SELECT …) LOOP` abre, recorre y cierra el cursor solo.

**Pantalla:** Alt+Tab a la presentación, diapositiva 7.

---

## Parte 3 · Martín Narváez (3:30)

### Diapositiva 7 · Package

**Decir:**
"Gracias. Un package junta en un objeto todo lo de facturación. Tiene una especificación, que es lo público, y un cuerpo, donde además puede haber partes privadas que solo se usan adentro."

**Pantalla:** Alt+Tab a SQL Developer, pestaña `04_package.sql`.

**Abrir:** `sql/04_package.sql`, **líneas 8 a 12**.

**Decir:**
"La especificación, de la línea 8 a la 12, tiene tres cosas públicas: el proceso mensual, el resumen y la función de ingresos del mes."

**Cómo funciona:** la especificación solo declara nombres y parámetros. Lo que está aquí se llama desde fuera como `pkg_facturacion.nombre`.

**Abrir:** `sql/04_package.sql`, **línea 19** y **líneas 25 a 34**.

**Decir:**
"En el cuerpo hay dos partes privadas, porque no están en la especificación: print_line, en la línea 19, que imprime mensajes, y fn_clasificar, en la línea 25, que devuelve ALTO desde tres millones, MEDIO desde un millón, y BAJO si es menos. Esos tramos son el mismo supuesto de la EP1."

**Cómo funciona:** lo que está en el cuerpo y no en la especificación es privado: el package lo usa, pero desde fuera no existe. `print_line` es igual al ejemplo `sales_reporting` de la guía de packages.

**Abrir:** `sql/04_package.sql`, **líneas 50 a 96**.

**Decir:**
"sp_generar_resumen, en la línea 50, agrupa las facturas por tipo de equipo con GROUP BY, usa la función privada en la línea 70, y en la línea 78 decide si inserta el resumen o lo actualiza, para no repetir la clave."

**Cómo funciona:** `GROUP BY` junta las facturas del mismo tipo y `COUNT` / `SUM` se calculan por grupo. La clave de `RESUMEN_ARRIENDO_TIPO` es tipo + mes + año; si ya existe, se hace `UPDATE` (línea 83) en vez de `INSERT` (línea 79).

**Abrir:** `sql/04_package.sql`, **líneas 99 a 105**.

**Decir:**
"Y sp_proceso_mensual, en la línea 99, es el punto de entrada: en la línea 102 llama al procedimiento de Gustavo, después genera el resumen y muestra el total del mes."

**Cómo funciona:** `sp_generar_facturas` está fuera del package (archivo 03); el package lo llama por su nombre. Así un procedimiento se usa dentro de otro programa PL/SQL.

**Pantalla:** Alt+Tab a la presentación, diapositiva 8.

### Diapositiva 8 · Triggers

**Decir:**
"Un trigger se ejecuta solo cuando pasa algo en una tabla. El de fila se ejecuta una vez por cada fila; el de sentencia, una vez por sentencia, aunque afecte muchas filas."

**Pantalla:** Alt+Tab a SQL Developer, pestaña `05_triggers.sql`.

**Abrir:** `sql/05_triggers.sql`, **líneas 6 a 16**.

**Decir:**
"trg_valida_factura es BEFORE INSERT, en la línea 7, para revisar antes de guardar, y FOR EACH ROW, en la línea 8, que lo hace de fila. Con dos puntos NEW revisa que los días sean al menos uno y, en la línea 14, que el total sea igual al neto más el IVA; el símbolo menor y mayor significa 'distinto de'. Si algo no cuadra, RAISE_APPLICATION_ERROR cancela el INSERT."

**Cómo funciona:** `:NEW.columna` es el valor que se intenta insertar. `RAISE_APPLICATION_ERROR` corta el `INSERT` con los códigos −20001 (días) y −20002 (total). El comentario de la línea 13 explica el `<>`.

**Abrir:** `sql/05_triggers.sql`, **líneas 21 a 33**.

**Decir:**
"trg_auditoria_factura, en la línea 22, es AFTER INSERT OR UPDATE OR DELETE y no tiene FOR EACH ROW, así que es de sentencia. Con INSERTING, UPDATING y DELETING anota la operación en la tabla de auditoría."

**Cómo funciona:** sin `FOR EACH ROW` corre una vez por sentencia. Inserta en `auditoria_factura` un número de `seq_auditoria_factura.NEXTVAL`, la operación y `SYSDATE` (tabla y secuencia en `01_auditoria.sql`).

**Pantalla:** Alt+Tab a la presentación, diapositiva 9.

### Diapositiva 9 · Resultado de marzo

**Decir:**
"Este es el resultado de marzo: todo queda en ALTO, salvo Proyector, que queda en MEDIO."

### Diapositiva 10 · Supuestos y código fuera de las guías

**Decir:**
"Y estos son nuestros supuestos, y las seis cosas que usamos que no están en las guías. Cada una está marcada con un comentario en el código. Ahora lo vemos funcionando."

**Pantalla:** Alt+Tab a SQL Developer, pestaña `06_demo.sql`.

---

## Parte 4 · Demostración final (3:00)

Todo se ejecuta en `sql/06_demo.sql`, salvo los pasos 6 y 7, que están en `pruebas/pruebas_ep2.sql`. Los resultados de abajo son los que salieron al probarlo en Oracle.

### Javier: funciones

**Paso 1.** **Abrir:** `sql/06_demo.sql`, **línea 11**. **Ejecutar:** Ctrl+Enter.

**Decir:**
"La función sin parámetros, usada en un SELECT: todavía da cero."

**Deberían ver:** `0`.

**Paso 2.** **Abrir:** `sql/06_demo.sql`, **líneas 14 a 21**. **Ejecutar:** cursor dentro de la consulta y Ctrl+Enter.

**Decir:**
"Y las funciones con parámetros, en un SELECT sobre los 103 arriendos: por cada fila calcula el porcentaje y el monto neto. Gustavo."

**Deberían ver:** columnas `ID_ARRIENDO`, `ID_TIPO_CLI`, `MONTO_BRUTO`, `PCT_AJUSTE`, `MONTO_NETO`; 103 filas (SQL Developer muestra 50 y carga el resto al bajar). Por ejemplo `1 · S · 360000 · -15 · 306000`.

### Gustavo: procedimientos

**Paso 3.** **Abrir:** `sql/06_demo.sql`, **líneas 24 a 27**. **Ejecutar:** seleccionar las 4 líneas y F5.

**Decir:**
"Llamamos al package con marzo de 2026. 'Facturas generadas: 23' lo imprime mi procedimiento, que el package llamó por dentro."

**Deberían ver** en el Script Output:
```
=== Proceso mensual 3/2026 ===
Facturas generadas: 23
Resumen por tipo de equipo 3/2026
Proyector: 6 arriendos, $2813160 (MEDIO)
Sistema de Sonido: 5 arriendos, $3688762 (ALTO)
Iluminación Escénica: 4 arriendos, $4370275 (ALTO)
Pantalla LED: 4 arriendos, $5208630 (ALTO)
Consola de Mezcla: 4 arriendos, $3155642 (ALTO)
Total facturado del mes: $19236469
```
(El orden de las 5 líneas del resumen puede variar.)

**Paso 4.** **Abrir:** `sql/06_demo.sql`, **líneas 33 a 36**. **Ejecutar:** seleccionar las 4 líneas y F5.

**Decir:**
"Y el procedimiento sin parámetros lista las 23 facturas y termina con el total. Martín."

**Deberían ver:** `Reporte de facturas`, 23 líneas `Arriendo: …, Cliente: …, Total: …` y al final `Total de facturas: 23`.

### Martín: package y triggers

**Paso 5.** **Abrir:** `sql/06_demo.sql`, **línea 40**, Ctrl+Enter; después **línea 42**, Ctrl+Enter.

**Decir:**
"La función pública del package, en un SELECT, da el total de marzo. Y este es el resumen: cuatro tipos en ALTO y Proyector en MEDIO."

**Deberían ver:** `19236469`, y después 5 filas: Pantalla LED 5208630 ALTO, Iluminación Escénica 4370275 ALTO, Sistema de Sonido 3688762 ALTO, Consola de Mezcla 3155642 ALTO, Proyector 2813160 MEDIO (el orden puede variar).

**Paso 6.** **Abrir:** pestaña `pruebas/pruebas_ep2.sql`, **líneas 154 a 157** (ya sin guiones, ver punto 7 de la sección 0). **Ejecutar:** seleccionar las 4 líneas y F5.

**Decir:**
"Si llamo a la función privada desde fuera, Oracle dice que no está declarada: fuera del package no existe."

**Deberían ver:** `PLS-00302: component 'FN_CLASIFICAR' must be declared` (en español: *el componente 'FN_CLASIFICAR' debe ser declarado*).

**Paso 7.** **Abrir:** `pruebas/pruebas_ep2.sql`, **líneas 102 a 111**. **Ejecutar:** seleccionar las líneas y F5.

**Decir:**
"Esta factura tiene un total que no cuadra, y el trigger de fila la rechaza con el error menos veinte mil dos."

**Deberían ver:** `OK   Prueba 9: trigger rechazó la factura -> ORA-20002: El total no coincide con neto + IVA`. Pueden salir después líneas `ORA-06512` / `ORA-04088`; es normal.

**Cómo funciona:** el `INSERT` trae neto 204.000 e IVA 38.760, pero total 1; el trigger lo compara en `05_triggers.sql` línea 14.

**Paso 8.** Volver a `sql/06_demo.sql`. **Línea 43**, Ctrl+Enter; **línea 48**, Ctrl+Enter; **línea 49**, Ctrl+Enter.

**Decir** (repartido mientras se ejecuta cada línea):
"En la auditoría hay 23 INSERT, uno por cada sentencia. Ahora borro las 23 facturas con un solo DELETE. Y en la auditoría aparece una sola línea nueva, DELETE: el trigger de sentencia se ejecutó una sola vez."

**Deberían ver:** primero 23 filas `INSERT`; después `23 rows deleted.`; después 24 filas, con una sola `DELETE` (puede no salir al final; buscarla en la columna `OPERACION`).

**Pantalla:** Alt+Tab a la presentación, diapositiva 11.

---

## Parte 5 · Cierre (0:30)

### Diapositiva 11 · Conclusión

**Javier dice:**
"En resumen: las funciones dejan cada cálculo en un solo lugar,"

**Gustavo dice:**
"los procedimientos facturan todo el mes con una sola llamada,"

**Martín dice:**
"y el package ordena todo, mientras los triggers validan y auditan solos."

### Diapositiva 12 · Preguntas

**Javier dice:**
"Muchas gracias. ¿Tienen alguna pregunta?"

**Si el profesor pide ejecutar algo más:** primero ejecutar `sql/06_demo.sql` líneas 52 a 56 (F5) para volver a generar las facturas, porque el paso 8 las borró.

---

## 6. Respuestas a preguntas probables

Responde el que defendió ese tema. Las respuestas también están escritas para decirlas tal cual.

**Funciones (Javier)**
- *"¿Por qué función y no procedimiento?"*
  "Porque devuelve un valor y la queremos usar dentro de un SELECT. Un procedimiento no se puede usar en un SELECT."
- *"¿Qué pasa si llega un tipo de cliente que no existe?"*
  "Cae en NO_DATA_FOUND, en la línea 23 de `02_funciones.sql`, y devuelve cero, o sea, sin ajuste."
- *"¿Por qué usaron %TYPE?"*
  "Para que la variable tenga el mismo tipo que la columna. Si cambia la columna, la variable se ajusta sola." (`02_funciones.sql`, línea 16)
- *"¿De dónde sacaron el 19 por ciento?"*
  "El caso no indica la tasa, así que usamos el IVA de Chile, el mismo supuesto de la EP1. Está en una sola línea, la 40 de `02_funciones.sql`."

**Procedimientos (Gustavo)**
- *"¿Qué pasa si lo ejecutan dos veces?"*
  "La segunda vez cada arriendo cae en el ELSE de la línea 68 y dice que ya estaba facturado. Se generan cero facturas nuevas."
- *"¿Por qué con parámetros?"*
  "Para facturar cualquier mes sin cambiar el código. Solo cambian el 3 y el 2026."
- *"¿Para qué sirve uno sin parámetros?"*
  "Para tareas que siempre son iguales, como listar todo lo facturado."
- *"¿Se puede usar un procedimiento en un SELECT?"*
  "No, solo las funciones. El procedimiento se usa desde otros bloques PL/SQL, como el package en la línea 102 de `04_package.sql`."

**Package (Martín)**
- *"¿Qué es público y qué es privado?"*
  "Público es lo que está en la especificación, en las líneas 9 a 11. Privado es lo que solo está en el cuerpo: print_line y fn_clasificar."
- *"¿Por qué hacerlos privados?"*
  "Porque son detalles internos. Nadie de fuera necesita clasificar un ingreso suelto, y así podemos cambiar la regla sin afectar a quien usa el package."
- *"¿Por qué guardan fn_clasificar en una variable?"*
  "Para calcularla una sola vez, en la línea 70, y usar el mismo resultado al guardar el resumen y en el mensaje."
- *"¿Qué ganan con el package?"*
  "Un solo punto de entrada para todo el proceso, el código ordenado en un lugar, y la posibilidad de esconder lo interno."

**Triggers (Martín)**
- *"¿Cuál es la diferencia entre fila y sentencia?"*
  "El de fila se ejecuta una vez por cada fila afectada y puede leer :NEW y :OLD. El de sentencia se ejecuta una vez por sentencia y no ve los valores de las filas."
- *"¿Por qué la auditoría es de sentencia?"*
  "Porque queremos saber qué operación se hizo y cuándo, no el detalle de cada fila. Con uno de fila, un DELETE masivo llenaría la tabla de auditoría."
- *"¿Por qué el de validación es BEFORE?"*
  "Para que el dato malo no alcance a guardarse."
- *"¿Desventajas?"*
  "Cada trigger de fila agrega trabajo en cada INSERT. Con millones de filas habría que medir el rendimiento."

**Generales (cualquiera)**
- *"¿Esto lo hicieron con IA?"*
  Responder con la verdad. Lo que importa es poder explicar cada línea: abrir el archivo y explicar la parte que pregunte.
- *"Cambien el IVA a 20 por ciento en vivo."*
  `02_funciones.sql` línea 40: cambiar `19` por `20` y F5 en el archivo. Después `pruebas/limpieza.sql` (F5) y volver a ejecutar el paso 3 de la demostración.
- *"¿Qué pasa con un tipo de cliente sin ajuste?"*
  "fn_obtener_pct_ajuste devuelve cero por el NO_DATA_FOUND, y el procedimiento lo marca como SIN AJUSTE, en la línea 58."
- *"¿Por qué no usaron un solo bloque anónimo como en la EP1?"*
  "Porque un bloque anónimo no queda guardado en la base ni se puede reutilizar. Los procedimientos, funciones y packages sí."
- *"¿Qué pasa si un INSERT falla a mitad del proceso?"*
  "El trigger lanza el error, el WHEN OTHERS del procedimiento lo muestra con SQLERRM, y el proceso se detiene sin caerse."

---

## 7. Código que no aparece en las guías del ramo

| Código | Dónde | Por qué se usó | Cómo funciona | Resultado |
|---|---|---|---|---|
| `SET SERVEROUTPUT ON` | `06_demo.sql` línea 8, `pruebas_ep2.sql` línea 7 | Sin esto SQL Developer no muestra lo que imprime `DBMS_OUTPUT.PUT_LINE`. Es un comando de la herramienta, no de PL/SQL. | Activa la salida de `DBMS_OUTPUT` en el Script Output. | Se ven los mensajes "Facturas generadas: 23", etc. |
| `EXTRACT(MONTH/YEAR FROM fecha)` | `03_procedimientos.sql` líneas 18–19, `04_package.sql` líneas 44–45 y 60–61 | Hay que filtrar los arriendos de un mes y año. El script del caso usa `EXTRACT(YEAR FROM SYSDATE)`; nosotros lo usamos igual y también con `MONTH`. | Saca el número del mes o del año de una fecha. | Solo se procesan los arriendos de marzo 2026. |
| `<>` | `05_triggers.sql` línea 14 | Para comparar si el total es distinto de neto + IVA. Es el operador "distinto de" de SQL básico. | Es verdadero cuando los dos valores no son iguales. | Si no cuadra, el trigger lanza ORA-20002 y la factura no se guarda. |
| `COMMIT` | `06_demo.sql` líneas 30 y 56, `pruebas_ep2.sql` línea 149, `limpieza.sql` línea 10 | Para dejar guardados los datos. El script del caso termina con `COMMIT`. | Confirma la transacción. | Los datos quedan aunque se cierre SQL Developer. |
| `DROP TABLE / DROP SEQUENCE` | `01_auditoria.sql` líneas 8–9 | Para poder ejecutar el archivo más de una vez. El script del caso hace lo mismo. | Borra la tabla o secuencia si existe. | La primera vez muestra ORA-00942 / ORA-02289 (no existe) y es normal. |
| `DELETE FROM tabla` | `06_demo.sql` línea 48, `pruebas_ep2.sql` línea 133, `limpieza.sql` líneas 7–9 | Para demostrar el trigger de sentencia con una sola sentencia que afecta muchas filas, y para limpiar antes de ensayar. Es SQL básico. | Borra las filas de la tabla. | La auditoría suma solo 1 línea aunque se borren 23 filas. |

---

## 8. Justificación por indicador (60% de la nota)

**Procedimientos**
- Automatizan una tarea que se repite cada mes y procesan muchas filas de una vez (23 arriendos en marzo).
- Con parámetros: sirve para cualquier mes. Sin parámetros: tareas fijas como el reporte.
- Se reutilizan: el package llama a `sp_generar_facturas`.
- Se ejecutan en el servidor: menos idas y vueltas entre el cliente y la base.

**Funciones**
- Encapsulan cálculos que se repiten (ajuste, IVA). Si cambia el IVA, se cambia en una línea.
- Devuelven un valor, por eso se pueden usar en un `SELECT` sobre los 103 arriendos y también dentro de procedimientos.
- `NO_DATA_FOUND` hace que un dato raro no detenga todo el proceso.

**Package**
- Agrupa todo lo de facturación en un solo objeto con un punto de entrada (`sp_proceso_mensual`).
- La especificación es lo público; el cuerpo esconde los detalles (`print_line`, `fn_clasificar`).
- Lo privado se puede cambiar sin afectar a quien usa el package.

**Triggers**
- De fila: validan cada factura antes de guardarla, sin importar desde dónde se haga el INSERT.
- De sentencia: auditan cada operación una sola vez, sin llenar la auditoría con una línea por fila.
- Se ejecutan solos: nadie tiene que acordarse de validar o auditar.

---

## 9. Si algo falla en vivo

| Síntoma | Qué hacer |
|---|---|
| No aparece ningún mensaje | Ejecutar con F5 la línea 8 de `06_demo.sql` (`SET SERVEROUTPUT ON;`). |
| El paso 1 no da 0, o sale `Facturas generadas: 0` y "ya estaba facturado" | Ya se había ejecutado antes. Ejecutar `pruebas/limpieza.sql` (F5) y empezar la demostración de nuevo. |
| `ORA-04098: trigger … no válido` | Volver a ejecutar `01_auditoria.sql` y después `05_triggers.sql`. |
| No hay auditoría ni validación después de recargar la base | El script del caso borró los triggers junto con `FACTURA_ARRIENDO`. Ejecutar otra vez `01` a `05`. |
| "compiled with errors" | `SELECT * FROM user_errors;` y revisar la línea que indica. |
| El paso 6 no da error y muestra un texto | Las líneas siguen con `--` (comentadas) o no quedaron seleccionadas las 4. |
| El resumen sale vacío | El año no coincide: revisar con `SELECT DISTINCT EXTRACT(YEAR FROM fecha_ini_arriendo) FROM arriendo_equipo_av;` y cambiar 2026. |

---

## 10. Práctica antes del día (cada uno)

1. Leer su parte en voz alta con cronómetro, cambiando entre la presentación y SQL Developer. Cada uno debe quedar dentro del tiempo de la tabla de la sección 1.
2. Explicar su archivo **sin mirar este guion**, usando solo las secciones "Cómo funciona".
3. Explicar el archivo de un compañero.
4. Hacer en vivo un cambio pequeño: el IVA a 20 %, el tramo de ALTO a 5.000.000 o el mes 2 en vez del 3.
5. Responder "¿qué pasaría si borro la línea X?" para 3 líneas al azar de su archivo.
