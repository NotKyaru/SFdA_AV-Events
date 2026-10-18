# Guion - Presentación EP2 · AV EVENTS

**BDY1103 Taller de Base de Datos · Evaluación Parcial N° 2**
Integrantes: Gustavo Giha · Javier Jorquera · Martín Narváez
Docente: Marco Antonio Japke Adriasola

> Cómo leer este guion
> - **Decir:** idea a explicar *con sus palabras* (no leerlo textual).
> - **Mostrar:** archivo y líneas a señalar en SQL Developer.
> - **Ejecutar:** seleccionar esas líneas y presionar **F5** (bloques PL/SQL) o **Ctrl+Enter** (un `SELECT`, se ve como tabla).
> - **Deberían ver:** lo que aparece si todo salió bien.
> - **Pregunta probable:** lo que el profesor puede preguntar, con una respuesta corta.

---

## 0. Antes de presentar (checklist)

1. En SQL Developer ejecutar con F5, en este orden:
   `BD_arriendo_equipos_AV_EVENTS.sql` → `sql/01_auditoria.sql` → `02` → `03` → `04` → `05`.
   **Ojo:** si vuelven a ejecutar el script del caso, este borra `FACTURA_ARRIENDO` (`DROP TABLE … CASCADE CONSTRAINTS`) y con ella se borran sus triggers. Después hay que ejecutar otra vez `01` a `05`.
2. Revisar que todo quedó **VALID**:
   ```sql
   SELECT object_name, object_type, status FROM user_objects
   WHERE object_type IN ('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY','TRIGGER');
   ```
3. Ejecutar `pruebas/limpieza.sql` para partir con las tablas vacías.
4. Dejar abiertos en pestañas: `02_funciones.sql`, `03_procedimientos.sql`, `04_package.sql`, `05_triggers.sql`, `06_demo.sql`.
5. Ejecutar `SET SERVEROUTPUT ON;` (línea 8 de `06_demo.sql`) para que los mensajes aparezcan en el Script Output.
6. Subir el tamaño de letra del editor para que se lea desde atrás (en inglés: Tools → Preferences → Code Editor → Fonts; en español: Herramientas → Preferencias → Editor de código → Fuentes).
7. Ensayar con cronómetro. Cada uno debe poder explicar **cualquier** archivo, no solo el suyo.

---

## 1. Reparto

| Quién | Diapositivas | Archivo que defiende | Rúbrica |
|---|---|---|---|
| Javier Jorquera | 1 a 5 | `sql/02_funciones.sql` | Funciones (IE2.1.3 / IE2.1.4) |
| Gustavo Giha | 6 | `sql/03_procedimientos.sql` | Procedimientos (IE2.1.1 / IE2.1.2) |
| Martín Narváez | 7 a 10 | `sql/04_package.sql`, `sql/05_triggers.sql` | Package (IE2.2.x) y Triggers (IE2.3.x) |
| Los tres | 11 y 12 | — | Conclusión y preguntas |

Es el mismo reparto de roles de la actividad 1.4.1 del ramo (Estudiante 1 procedimientos, Estudiante 2 funciones, Estudiante 3 packages y triggers).

---

## 2. Guion por diapositiva

### Diapositiva 1 · Portada — Javier

**Decir:** "Buenas tardes. Somos Gustavo, Martín y yo, Javier. Les vamos a mostrar cómo automatizamos la facturación mensual de AV EVENTS usando procedimientos, funciones, un package y triggers."

### Diapositiva 2 · Agenda y reparto — Javier

**Decir:** "Yo parto con el problema y las funciones; Gustavo explica los procedimientos; Martín el package y los triggers. Al final hacemos la demostración completa y respondemos preguntas."

### Diapositiva 3 · El problema — Javier

**Decir:**
- AV EVENTS arrienda equipos audiovisuales. Cada arriendo queda en `ARRIENDO_EQUIPO_AV`, pero nadie calcula la factura.
- Para cobrar hay que: días × valor diario, aplicar el ajuste según tipo de cliente (Socio -15%, Premium -10%, Nacional -5%, Extranjero +8%) y sumar IVA.
- El resultado se guarda en `FACTURA_ARRIENDO` y se resume por tipo de equipo en `RESUMEN_ARRIENDO_TIPO`. Las dos tablas venían vacías en el script del caso.

**Pregunta probable:** "¿De dónde sacaron el 19%?"
**Respuesta:** "El caso no indica la tasa; usamos el IVA vigente en Chile, el mismo supuesto que declaramos en la EP1. Está en una sola función, así que cambiarlo es tocar una línea."

### Diapositiva 4 · Cómo se conecta todo — Javier

**Decir:** recorrer el diagrama de arriba hacia abajo:
"El package llama al procedimiento que genera facturas; ese procedimiento usa nuestras funciones; cada INSERT dispara los triggers. Al final el package arma el resumen."

### Diapositiva 5 · Funciones — Javier

**Mostrar:** `sql/02_funciones.sql`

| Líneas | Qué explicar |
|---|---|
| 6–11 | `fn_total_facturas`, **sin parámetros**. Cuenta las facturas con `COUNT(*)` y devuelve el número con `RETURN`. |
| 15–25 | `fn_obtener_pct_ajuste`, **con parámetro** (tipo de cliente). Busca el % en `AJUSTE_CLIENTE`. |
| 22–24 | Si el tipo no existe, `NO_DATA_FOUND` devuelve 0: el proceso no se cae. |
| 30–33 | `fn_aplicar_ajuste`: monto + (monto × % / 100). Como el % de descuento es negativo, resta. |
| 38–41 | `fn_calcular_iva`: neto × 19 / 100. |

**Ejecutar:** `sql/06_demo.sql`
- Línea 11 (Ctrl+Enter): `SELECT fn_total_facturas FROM dual;`
  **Deberían ver:** `0` (todavía no hay facturas).
- Líneas 14–21 (Ctrl+Enter): consulta sobre **todos los arriendos** con las funciones dentro del `SELECT`.
  **Deberían ver:** filas con monto bruto, % de ajuste y monto neto. Son 103 en total; SQL Developer muestra las primeras 50 y carga el resto al bajar.

**Decir:** "Esto demuestra que la función se usa dentro de una sentencia SQL y procesa información masiva: se ejecuta una vez por cada uno de los 103 arriendos."

**Preguntas probables:**
- "¿Por qué función y no procedimiento?" → "Porque devuelve un valor y la queremos usar dentro de un SELECT. Un procedimiento no se puede usar en un SELECT."
- "¿Qué pasa si llega un tipo de cliente que no existe?" → "Cae en NO_DATA_FOUND (línea 23) y devuelve 0, o sea, sin ajuste."
- "¿Por qué `%TYPE` en la línea 16?" → "Para que la variable tenga el mismo tipo que la columna; si cambia la columna, la variable se ajusta sola."

### Diapositiva 6 · Procedimientos — Gustavo

**Mostrar:** `sql/03_procedimientos.sql`

| Líneas | Qué explicar |
|---|---|
| 7–10 | `sp_generar_facturas` recibe **dos parámetros IN**: mes y año. |
| 12–19 | Cursor **con parámetros**: trae los arriendos del mes uniendo arriendo, equipo y cliente. |
| 11 | Comentario: `EXTRACT` no está en las guías; el script del caso lo usa con `YEAR` (ver sección 3). |
| 21–34 | Variables con `%TYPE`, una por cada dato de la factura. |
| 36–40 | `OPEN` / `FETCH` / `EXIT WHEN %NOTFOUND`: recorre fila por fila, igual que en la unidad 1. |
| 43–47 | Revisa con `COUNT(*)` si el arriendo ya tiene factura, para no duplicar. |
| 48–61 | Calcula usando **las funciones del archivo 02** (líneas 49, 50 y 61). |
| 53–59 | `IF / ELSIF` decide si es DESCUENTO, RECARGO o SIN AJUSTE. |
| 63–66 | Inserta la factura. |
| 74–76 | `WHEN OTHERS` + `SQLERRM`: si algo falla, muestra el error en vez de caerse. |
| 81–93 | `sp_reporte_facturas`, **sin parámetros**: recorre todas las facturas y al final usa `fn_total_facturas` (línea 92). |

**Ejecutar:** `sql/06_demo.sql`
- Líneas 24–27 (F5): `pkg_facturacion.sp_proceso_mensual(3, 2026);`
  **Deberían ver** en el output: `Facturas generadas: 23`, luego 5 líneas de resumen y `Total facturado del mes: $19236469`.
- Línea 30 (F5): `COMMIT;`
- Líneas 33–36 (F5): `sp_reporte_facturas;`
  **Deberían ver:** 23 líneas "Arriendo: …, Cliente: …, Total: …" y al final `Total de facturas: 23`.

**Decir:** "El proceso lo lanzamos desde el package, pero las 23 facturas las genera mi procedimiento: el package lo llama en su línea 102. Eso es usar un procedimiento dentro de otro programa PL/SQL."

**Preguntas probables:**
- "¿Qué pasa si lo ejecutan dos veces?" → "La segunda vez cada arriendo cae en el ELSE (línea 69) y dice 'ya estaba facturado'; quedan 0 facturas nuevas."
- "¿Por qué con parámetros?" → "Para facturar cualquier mes sin cambiar el código; solo cambian el 3 y el 2026."
- "¿Para qué sirve uno sin parámetros?" → "Para tareas que siempre son iguales, como listar todo lo facturado."
- "¿Se puede usar un procedimiento en un SELECT?" → "No, solo funciones. El procedimiento se usa desde otros bloques PL/SQL, como el package."

### Diapositiva 7 · Package — Martín

**Mostrar:** `sql/04_package.sql`

| Líneas | Qué explicar |
|---|---|
| 8–12 | **Especificación**: lo público. Solo 3 cosas se pueden llamar desde fuera. |
| 16 | **Cuerpo**: la implementación. |
| 18–22 | `print_line`, **procedimiento privado** (está en el cuerpo pero no en la especificación). Igual al ejemplo `sales_reporting` de la guía 2.2.5. |
| 24–34 | `fn_clasificar`, **función privada**: ALTO / MEDIO / BAJO según el ingreso (mismo supuesto de la EP1: ≥ 3.000.000 ALTO, ≥ 1.000.000 MEDIO). |
| 36–47 | `fn_ingresos_mes`, función pública: suma lo facturado en el mes. |
| 50–96 | `sp_generar_resumen`, público: agrupa por tipo de equipo con `GROUP BY`. |
| 68–70 | El resultado de la función privada se guarda en `v_clasificacion` (ver pregunta abajo). |
| 72–91 | Si el resumen ya existe lo actualiza (`UPDATE`), si no, lo inserta (`INSERT`). |
| 99–105 | `sp_proceso_mensual`, público: el punto de entrada. Llama al procedimiento del archivo 03 (línea 102), al resumen y a la función de ingresos. |

**Ejecutar:** `sql/06_demo.sql`
- Línea 40 (Ctrl+Enter): `SELECT pkg_facturacion.fn_ingresos_mes(3, 2026) FROM dual;`
  **Deberían ver:** `19236469`.
- Línea 42 (Ctrl+Enter): `SELECT * FROM resumen_arriendo_tipo;`
  **Deberían ver** 5 filas:

  | Tipo | Cantidad | Ingreso | Clasificación |
  |---|---|---|---|
  | Pantalla LED | 4 | 5.208.630 | ALTO |
  | Iluminación Escénica | 4 | 4.370.275 | ALTO |
  | Sistema de Sonido | 5 | 3.688.762 | ALTO |
  | Consola de Mezcla | 4 | 3.155.642 | ALTO |
  | Proyector | 6 | 2.813.160 | MEDIO |

  (El orden de las filas puede variar. Ningún tipo queda BAJO porque todos superan $1.000.000.)

- **Prueba en vivo de que es privado:** en `pruebas/pruebas_ep2.sql`, quitar los guiones de la Prueba 12 y ejecutar.
  **Deberían ver:** un error `PLS-00302` que dice que el componente `FN_CLASIFICAR` debe ser declarado (en inglés: *component 'FN_CLASIFICAR' must be declared*). Eso prueba que desde fuera no existe.

**Preguntas probables:**
- "¿Qué es público y qué es privado?" → "Público es lo que está en la especificación (líneas 9 a 11). Privado es lo que solo está en el cuerpo: `print_line` y `fn_clasificar`."
- "¿Por qué hacerlos privados?" → "Son detalles internos. Nadie de fuera necesita clasificar un ingreso suelto; así se puede cambiar la regla sin afectar a quien usa el package."
- "¿Por qué guardan `fn_clasificar` en una variable?" → "Para calcularla una sola vez (línea 70) y usar el mismo resultado en el INSERT o el UPDATE y en el mensaje de salida."
- "¿Qué ganan con el package?" → "Un solo punto de entrada para todo el proceso, código ordenado en un lugar y la posibilidad de ocultar lo interno."

### Diapositiva 8 · Triggers: fila vs sentencia — Martín

**Mostrar:** `sql/05_triggers.sql`

| Líneas | Qué explicar |
|---|---|
| 6–17 | `trg_valida_factura`: **a nivel de fila** (`FOR EACH ROW`, línea 8). Se ejecuta una vez por **cada** factura. |
| 7 | `BEFORE INSERT`: valida antes de guardar (las guías dicen: validar con BEFORE). |
| 10–16 | Usa `:NEW` para revisar los valores de esa fila; si están mal, `RAISE_APPLICATION_ERROR` cancela el INSERT. Línea 10: días menor que 1. Línea 14: `<>` significa "distinto de" (comentario en la línea 13). |
| 21–34 | `trg_auditoria_factura`: **a nivel de sentencia** (no tiene `FOR EACH ROW`). Se ejecuta **una vez por sentencia**, sin importar cuántas filas toque. |
| 22 | `AFTER INSERT OR UPDATE OR DELETE`: audita después (las guías dicen: auditar con AFTER). |
| 24–33 | `INSERTING / UPDATING / DELETING` dicen qué operación fue y la anota en `auditoria_factura`. |

**Ejecutar:** `sql/06_demo.sql`
1. Línea 43 (Ctrl+Enter): `SELECT * FROM auditoria_factura;`
   **Deberían ver:** 23 filas `INSERT`. Explicar: "Cada INSERT del procedimiento es una sentencia distinta, por eso hay 23."
2. Línea 48 (F5): `DELETE FROM factura_arriendo;` → mensaje de **23 filas borradas** (*23 rows deleted*).
3. Línea 49 (Ctrl+Enter): `SELECT * FROM auditoria_factura;`
   **Deberían ver:** 24 filas: solo **una** nueva, `DELETE`.

**Decir:** "Un solo DELETE borró 23 filas, pero el trigger de sentencia se ejecutó una sola vez. Si fuera de fila, habría 23 líneas DELETE."

4. Líneas 52–56 (F5): vuelve a generar las facturas para dejar todo listo.

**Prueba del trigger de fila:** en `pruebas/pruebas_ep2.sql` ejecutar la Prueba 9.
**Deberían ver:** una línea que empieza con `OK   Prueba 9: trigger rechazó la factura -> ORA-20002: El total no coincide con neto + IVA`. Oracle puede agregar después líneas `ORA-06512` / `ORA-04088` que indican en qué trigger ocurrió; es normal.

**Preguntas probables:**
- "¿Cuál es la diferencia entre fila y sentencia?" → "El de fila se ejecuta una vez por cada fila afectada y puede leer `:NEW` y `:OLD`. El de sentencia se ejecuta una vez por sentencia y no puede ver los valores de las filas."
- "¿Por qué la auditoría es de sentencia?" → "Porque queremos saber qué operación se hizo y cuándo, no el detalle de cada fila; con uno de fila un DELETE masivo llenaría la tabla de auditoría."
- "¿Por qué el de validación es BEFORE?" → "Para que el dato malo no alcance a guardarse."
- "¿Desventajas?" → "Cada trigger de fila agrega trabajo por cada INSERT; con millones de filas habría que medir el rendimiento."

### Diapositiva 9 · Resultado de marzo — Martín

**Decir:** "Este es el resumen que generó el package: ingreso por tipo de equipo y su clasificación. En total se facturaron $19.236.469 en 23 facturas."
**Mostrar:** el resultado de `SELECT * FROM resumen_arriendo_tipo;` (línea 42 de `06_demo.sql`) junto al gráfico.

**Pregunta probable:** "¿De dónde salen ALTO, MEDIO y BAJO?" → "El caso tiene la columna pero no da la regla. Usamos el mismo supuesto de la EP1: desde $3.000.000 es ALTO, desde $1.000.000 es MEDIO y menos es BAJO. Está en la función privada `fn_clasificar` (líneas 25–34 de `04_package.sql`)."

### Diapositiva 10 · Supuestos y código fuera de las guías — Martín

**Decir:** leer rápido la tabla de la diapositiva y decir: "Todo lo que no aparece en las guías lo marcamos con un comentario en el código y les explicamos por qué." (Detalle en la sección 3.)

### Diapositiva 11 · Conclusión — los tres (una idea cada uno)

- **Javier:** "Las funciones dejan cada cálculo en un solo lugar y se pueden usar en SQL y en PL/SQL."
- **Gustavo:** "Los procedimientos automatizan el trabajo del mes: con una llamada se facturan todos los arriendos."
- **Martín:** "El package ordena todo y oculta lo interno; los triggers validan y auditan solos, sin que nadie se acuerde de hacerlo."

### Diapositiva 12 · Preguntas — los tres

Ver la sección 5.

---

## 3. Código que NO aparece en las guías del ramo

| Código | Dónde | Por qué se usó | Cómo funciona | Resultado |
|---|---|---|---|---|
| `SET SERVEROUTPUT ON` | `06_demo.sql` línea 8, `pruebas_ep2.sql` | Sin esto SQL Developer no muestra lo que imprime `DBMS_OUTPUT.PUT_LINE`. Es un comando de la herramienta, no de PL/SQL. | Activa la salida del buffer de DBMS_OUTPUT en el Script Output. | Se ven los mensajes "Facturas generadas: 23", etc. |
| `EXTRACT(MONTH/YEAR FROM fecha)` | `03_procedimientos.sql` líneas 18–19, `04_package.sql` líneas 44–45 y 60–61 | Hay que filtrar los arriendos de un mes y año. El script del caso del profesor usa `EXTRACT(YEAR FROM SYSDATE)`; nosotros lo usamos igual y también con `MONTH`. | Saca el número del mes o del año de una fecha. | Solo se procesan los arriendos de marzo 2026. |
| `<>` | `05_triggers.sql` línea 14 | Para comparar si el total es distinto de neto + IVA. Es el operador "distinto de" de SQL básico. | Es verdadero cuando los dos valores no son iguales. | Si no cuadra, el trigger lanza ORA-20002 y la factura no se guarda. |
| `COMMIT` | `06_demo.sql` líneas 30 y 56, `pruebas_ep2.sql`, `limpieza.sql` | Para dejar guardados los datos. El script del caso termina con `COMMIT`. | Confirma la transacción. | Los datos quedan aunque se cierre SQL Developer. |
| `DROP TABLE / DROP SEQUENCE` | `01_auditoria.sql` líneas 8–9 | Para poder ejecutar el archivo más de una vez. El script del caso hace lo mismo. | Borra la tabla o secuencia si existe. | La primera vez muestra ORA-00942 / ORA-02289 (no existe) y es normal. |
| `DELETE FROM tabla` | `06_demo.sql` línea 48, `pruebas_ep2.sql` Prueba 11, `limpieza.sql` | Para demostrar el trigger de sentencia con una sola sentencia que afecta muchas filas, y para limpiar antes de ensayar. Es SQL básico. | Borra las filas de la tabla. | La auditoría suma solo 1 línea aunque se borren 23 filas. |

---

## 4. Justificación por indicador (60% de la nota)

**Procedimientos (IE2.1.2)**
- Automatizan una tarea que se repite cada mes y procesan muchas filas de una vez (23 arriendos en marzo).
- Con parámetros: sirve para cualquier mes. Sin parámetros: tareas fijas como el reporte.
- Se reutilizan: el package llama a `sp_generar_facturas`.
- Se ejecutan en el servidor: menos idas y vueltas entre el cliente y la base.

**Funciones (IE2.1.4)**
- Encapsulan cálculos que se repiten (ajuste, IVA). Si cambia el IVA, se cambia en una línea.
- Devuelven un valor, por eso se pueden usar en un `SELECT` sobre los 103 arriendos y también dentro de procedimientos.
- `NO_DATA_FOUND` hace que un dato raro no detenga todo el proceso.

**Package (IE2.2.2)**
- Agrupa todo lo de facturación en un solo objeto con un punto de entrada (`sp_proceso_mensual`).
- La especificación es el "contrato" público; el cuerpo esconde los detalles (`print_line`, `fn_clasificar`).
- Lo privado se puede cambiar sin afectar a quien usa el package.

**Triggers (IE2.3.2)**
- De fila: validan cada factura antes de guardarla (integridad), sin importar desde dónde se haga el INSERT.
- De sentencia: auditan cada operación una sola vez, sin llenar la auditoría con una línea por fila.
- Se ejecutan solos: nadie tiene que acordarse de validar o auditar.

---

## 5. Preguntas generales probables

- **"¿Esto lo hicieron con IA?"** → Responder con la verdad. Lo que importa es poder explicar cada línea: abrir el archivo y explicar la parte que pregunte.
- **"Cambien el IVA a 20% en vivo."** → `02_funciones.sql` línea 40: cambiar `19` por `20`, F5 en el archivo, limpiar (`limpieza.sql`) y volver a correr el proceso.
- **"Agreguen un tipo de cliente sin ajuste."** → `fn_obtener_pct_ajuste` devuelve 0 por el `NO_DATA_FOUND`, y el procedimiento lo marca 'SIN AJUSTE' (línea 58).
- **"¿Por qué no usaron un solo bloque anónimo como en la EP1?"** → "Porque un bloque anónimo no queda guardado en la base ni se puede reutilizar; los procedimientos, funciones y packages sí."
- **"¿Qué pasa si un INSERT falla a mitad del proceso?"** → "El trigger lanza el error, el `WHEN OTHERS` del procedimiento lo muestra con `SQLERRM` y el proceso se detiene sin caerse."

---

## 6. Si algo falla en vivo

| Síntoma | Qué hacer |
|---|---|
| No aparece ningún mensaje | Ejecutar `SET SERVEROUTPUT ON;` (línea 8 de la demo). |
| `Facturas generadas: 0` y "ya estaba facturado" | Ya se había corrido. Ejecutar `pruebas/limpieza.sql` y repetir. |
| `ORA-04098: trigger … no válido` | Volver a ejecutar `01_auditoria.sql` y después `05_triggers.sql`. |
| No hay auditoría ni validación después de recargar la base | El script del caso borró los triggers junto con `FACTURA_ARRIENDO`. Ejecutar otra vez `01` a `05`. |
| "compiled with errors" | `SELECT * FROM user_errors;` y revisar la línea que indica. |
| La consulta del resumen sale vacía | El año no coincide: revisar con `SELECT DISTINCT EXTRACT(YEAR FROM fecha_ini_arriendo) FROM arriendo_equipo_av;` y cambiar 2026. |

---

## 7. Práctica antes del día (cada uno)

1. Explicar en voz alta su archivo **sin mirar este guion**.
2. Explicar el archivo de un compañero.
3. Hacer en vivo un cambio pequeño: el IVA a 20%, el umbral de ALTO a 5.000.000 o el mes 2 en vez del 3.
4. Responder: "¿qué pasaría si borro la línea X?" para 3 líneas al azar de su archivo.
