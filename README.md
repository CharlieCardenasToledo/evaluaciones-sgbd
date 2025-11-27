**Puntaje total:** 8.0 puntos

## Introducción

Esta evaluación práctica te permitirá demostrar tu dominio de los contenidos de Semanas 1, 2, 3 y 4, relacionados con:

- Modelo lógico, físico y vistas (ANSI-SPARC)
- Transacciones y propiedades ACID
- Concurrencia, fallos, logging y recuperación (WAL / InnoDB)
- Optimización de consultas en MySQL (EXPLAIN / índices)

Trabajarás sobre un caso realista del **Programa de Lealtad de Aerolínea Canadiense**.

## CASO DE ESTUDIO: Programa de Lealtad — Aerolínea Canadiense

La Aerolínea Canadiense ofrece actualmente:

- Vuelos nacionales e internacionales
- Programa de lealtad con tres niveles (Star, Nova, Aurora)
- Acumulación y canje de puntos
- Sistema de seguimiento de actividad de vuelos

Aunque en el futuro planean incluir alianzas con hoteles y servicios adicionales, por ahora el foco principal es mejorar:

- La gestión de transacciones de canje de puntos
- El seguimiento de la actividad de vuelos de los clientes
- La optimización de consultas para análisis de marketing
- La integridad y recuperación de datos ante fallos

La administración desea implementar un sistema robusto de gestión de lealtad, construido con:

- Transacciones ACID seguras
- Logging y recuperación con InnoDB
- Índices optimizados para consultas frecuentes
- Control de concurrencia y consistencia de datos

## Esquema de trabajo para esta evaluación

**IMPORTANTE - IMPORTACIÓN DE BASE DE DATOS:**

Antes de comenzar la evaluación, debe importar la base de datos en el siguiente orden:

**Opción 1: Importación Manual (línea de comandos)**

```bash
# Paso 1: Crear la estructura de la base de datos
mysql -u root -p < 01_crear_base_datos_airline_loyalty.sql

# Paso 2: Cargar datos de calendar
mysql -u root -p airline_loyalty_db < Dump20251124/airline_loyalty_db_calendar.sql

# Paso 3: Cargar datos de customer_loyalty_history
mysql -u root -p airline_loyalty_db < Dump20251124/airline_loyalty_db_customer_loyalty_history.sql

# Paso 4: Cargar datos de customer_flight_activity
mysql -u root -p airline_loyalty_db < Dump20251124/airline_loyalty_db_customer_flight_activity.sql

# Paso 5: Cargar rutinas y procedimientos
mysql -u root -p airline_loyalty_db < Dump20251124/airline_loyalty_db_routines.sql
```

**Opción 2: MySQL Workbench**

1. Abrir MySQL Workbench
2. Conectar a tu servidor MySQL
3. Ir a: `Server → Data Import`
4. Seleccionar: `Import from Self-Contained File`
5. Importar en orden:
   - `01_crear_base_datos_airline_loyalty.sql`
   - `Dump20251124/airline_loyalty_db_calendar.sql`
   - `Dump20251124/airline_loyalty_db_customer_loyalty_history.sql`
   - `Dump20251124/airline_loyalty_db_customer_flight_activity.sql`
   - `Dump20251124/airline_loyalty_db_routines.sql`

**Verificar la carga correcta:**

```sql
USE airline_loyalty_db;
SHOW TABLES;
SELECT COUNT(*) FROM calendar;  -- Debe mostrar 2,559 registros
SELECT COUNT(*) FROM customer_loyalty_history;  -- Debe mostrar 16,739 registros
SELECT COUNT(*) FROM customer_flight_activity;  -- Debe mostrar 392,938 registros
```

---

## DICCIONARIO DE DATOS

Base de datos: `airline_loyalty_db` | Motor: InnoDB | Charset: utf8mb4_unicode_ci

### Tabla 1: calendar (2,559 registros)

Tabla dimensional de calendario para análisis temporal. Período: 2012-01-01 a 2018-12-31.

| # | Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|-------|------|------|-------|---------|-------------|
| 1 | date_id | DATE | NO | PK | - | Fecha específica única |
| 2 | start_of_year | DATE | NO | IDX | - | Primer día del año |
| 3 | start_of_quarter | DATE | NO | IDX | - | Primer día del trimestre |
| 4 | start_of_month | DATE | NO | IDX | - | Primer día del mes |
| 5 | year_num | INT | NO | IDX | - | Año numérico (2012-2018) |
| 6 | quarter_num | INT | NO | - | - | Trimestre (1-4) |
| 7 | month_num | INT | NO | - | - | Mes (1-12) |
| 8 | day_of_week | VARCHAR(20) | SI | - | NULL | Día de la semana |

---

### Tabla 2: customer_loyalty_history (16,739 registros)

Información demográfica y de membresía de clientes del programa de lealtad.

| # | Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|-------|------|------|-------|---------|-------------|
| 1 | loyalty_number | INT | NO | PK | - | Número único de lealtad |
| 2 | country | VARCHAR(50) | NO | - | - | País de residencia |
| 3 | province | VARCHAR(50) | SI | IDX | NULL | Provincia/estado |
| 4 | city | VARCHAR(100) | SI | - | NULL | Ciudad de residencia |
| 5 | postal_code | VARCHAR(20) | SI | - | NULL | Código postal |
| 6 | gender | ENUM('Male','Female') | SI | - | NULL | Género |
| 7 | education | VARCHAR(50) | SI | - | NULL | Nivel educativo |
| 8 | salary | DECIMAL(10,2) | SI | - | NULL | Ingreso anual (CAD) |
| 9 | marital_status | ENUM('Single','Married','Divorced') | SI | - | NULL | Estado civil |
| 10 | loyalty_card | ENUM('Star','Nova','Aurora') | NO | IDX | - | Nivel de tarjeta |
| 11 | clv | DECIMAL(10,2) | NO | IDX | - | Customer Lifetime Value |
| 12 | enrollment_type | VARCHAR(50) | NO | - | - | Tipo de inscripción |
| 13 | enrollment_year | INT | NO | IDX | - | Año de inscripción |
| 14 | enrollment_month | INT | NO | IDX | - | Mes de inscripción |
| 15 | cancellation_year | INT | SI | IDX | NULL | Año de cancelación |
| 16 | cancellation_month | INT | SI | IDX | NULL | Mes de cancelación |

**Índices compuestos:**
- `idx_enrollment` (enrollment_year, enrollment_month)
- `idx_cancellation` (cancellation_year, cancellation_month)

---

### Tabla 3: customer_flight_activity (392,938 registros)

Actividad mensual de vuelos, puntos y canjes por cliente.

| # | Campo | Tipo | Nulo | Clave | Default | Descripción |
|---|-------|------|------|-------|---------|-------------|
| 1 | activity_id | INT | NO | PK, AI | - | ID único de actividad |
| 2 | loyalty_number | INT | NO | FK, UNQ | - | Referencia al cliente |
| 3 | year | INT | NO | IDX, UNQ | - | Año del período |
| 4 | month | INT | NO | IDX, UNQ | - | Mes del período (1-12) |
| 5 | total_flights | INT | NO | IDX | 0 | Total de vuelos reservados |
| 6 | distance | INT | NO | - | 0 | Distancia en kilómetros |
| 7 | points_accumulated | INT | NO | IDX | 0 | Puntos ganados |
| 8 | points_redeemed | INT | NO | IDX | 0 | Puntos canjeados |
| 9 | dollar_cost_points_redeemed | DECIMAL(10,2) | NO | - | 0.00 | Valor en CAD de canjes |

**Relaciones:**
- FK: loyalty_number → customer_loyalty_history(loyalty_number) ON DELETE CASCADE ON UPDATE CASCADE

**Restricciones:**
- UNIQUE KEY `uk_customer_period` (loyalty_number, year, month) - Un registro por cliente por mes

**Índice compuesto:**
- `idx_year_month` (year, month)

---

### Reglas de Negocio

| Concepto | Regla | Notas |
|----------|-------|-------|
| **Niveles de Tarjeta** | Star (básico), Nova (intermedio), Aurora (premium) | Determinan beneficios y tasa de acumulación |
| **Acumulación de Puntos** | ~0.5 puntos por km volado | Varía según nivel de tarjeta |
| **Conversión de Puntos** | 200 puntos ≈ 10 CAD | Tasa aproximada para canjes |
| **Cliente Activo** | cancellation_year = NULL | Clientes cancelados tienen año/mes de cancelación |
| **Integridad Referencial** | CASCADE en eliminación | Eliminar cliente borra su actividad |
| **Período de Datos** | 2012-01-01 a 2018-12-31 | 7 años de historial |

---

## FASE 1: Transacciones Controladas (3.0 puntos)

Simule la operación real del programa de lealtad: cuando un cliente canjea puntos, se deben actualizar sus puntos acumulados, crear un registro de actividad de canje y registrar el valor en dólares.

Para esta fase, trabajará con una nueva tabla de transacciones de canje que debe crear:

```sql
CREATE TABLE redemption_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    loyalty_number INT NOT NULL,
    points_used INT NOT NULL,
    dollar_value DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL,
    status ENUM('PENDING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    FOREIGN KEY (loyalty_number) REFERENCES customer_loyalty_history(loyalty_number)
) ENGINE=InnoDB;

-- Agregar columna de puntos disponibles a la tabla de clientes
ALTER TABLE customer_loyalty_history
ADD COLUMN available_points INT DEFAULT 0;

-- Inicializar puntos disponibles con datos de actividad
UPDATE customer_loyalty_history clh
SET available_points = (
    SELECT SUM(points_accumulated) - SUM(points_redeemed)
    FROM customer_flight_activity cfa
    WHERE cfa.loyalty_number = clh.loyalty_number
);
```

### a) Genere y ejecute una transacción completa (1.5 puntos)

**Instrucciones:**

Complete el siguiente código SQL para realizar una transacción de canje de puntos. Debe llenar los espacios marcados con `______` con el código SQL correcto.

**IMPORTANTE - Datos de Transacción:**

> **Nota:** La base de datos `airline_loyalty_db` contiene datos históricos solo hasta **2018**. Por lo tanto:
> - Use la fecha **`'2018-12-31'`** para las transacciones (en lugar de `CURDATE()`)
> - Use **`year = 2018`** y **`month = 12`** para actualizar la tabla `customer_flight_activity`
> - Esto garantiza que el UPDATE afecte filas reales en la base de datos

**Paso 1:** Primero, consulte un cliente con puntos suficientes Y que tenga actividad en diciembre 2018:

```sql
SELECT clh.loyalty_number, clh.available_points
FROM customer_loyalty_history clh
INNER JOIN customer_flight_activity cfa
    ON clh.loyalty_number = cfa.loyalty_number
WHERE clh.available_points > 5000
  AND cfa.year = 2018
  AND cfa.month = 12
LIMIT 1;
```

**Paso 2:** Complete la transacción (reemplace `______` con el código correcto):

```sql
START TRANSACTION;

-- 1. Reducir puntos disponibles del cliente
UPDATE customer_loyalty_history
SET available_points = ______   -- Complete: restar los puntos canjeados
WHERE loyalty_number = ______   -- Complete: número de lealtad del cliente
  AND available_points >= ______; -- Complete: validar puntos suficientes

-- 2. Registrar la transacción de canje
INSERT INTO redemption_transactions
(loyalty_number, points_used, dollar_value, transaction_date, status)
VALUES (______, ______, ______, ______, ______);
-- Complete los valores: loyalty_number, puntos_canjeados, valor_dolares, fecha_actual, estado

-- 3. Actualizar el registro de actividad del mes actual
UPDATE customer_flight_activity
SET points_redeemed = ______,  -- Complete: incrementar puntos canjeados
    dollar_cost_points_redeemed = ______  -- Complete: incrementar valor en dólares
WHERE loyalty_number = ______
  AND year = ______   -- Complete: año actual
  AND month = ______; -- Complete: mes actual

COMMIT;
```

**Ayudas:**
- Para la fecha de transacción use: `'2018-12-31'` (último día del año con datos)
- Para año/mes de actividad use: `year = 2018`, `month = 12`
- Tasa de conversión: 200 puntos ≈ 10 CAD (dólares canadienses - calcule proporcionalmente)
  - Ejemplo: 5000 puntos = (5000 ÷ 200) × 10 = 250.00 CAD
- El status debe ser: `'COMPLETED'`

**Evidencia solicitada:**

- Captura de la consulta SELECT inicial (cliente seleccionado con sus puntos)
- Captura de la transacción completa ejecutada (con los espacios completados)
- Captura de puntos disponibles DESPUÉS de la transacción
- Captura del registro insertado en redemption_transactions
- Captura del registro actualizado en customer_flight_activity

### b) Simule un error y aplique ROLLBACK (1.5 puntos)

**Instrucciones:**

Elija UNA de las siguientes opciones de error y complete el código SQL:

**Opción A: Puntos insuficientes**

```sql
-- Consulte los puntos actuales del cliente
SELECT loyalty_number, available_points
FROM customer_loyalty_history
WHERE loyalty_number = ______;  -- Complete: use el mismo cliente del ejercicio anterior

START TRANSACTION;

-- Intente canjear MÁS puntos de los disponibles
UPDATE customer_loyalty_history
SET available_points = available_points - ______  -- Complete: cantidad mayor a puntos disponibles
WHERE loyalty_number = ______
  AND available_points >= ______;  -- Complete: misma cantidad (condición fallará)

-- Verifique que no se actualizó ninguna fila
SELECT ROW_COUNT() AS filas_afectadas;

-- Si filas_afectadas = 0, hacer ROLLBACK
ROLLBACK;

-- Verifique que los puntos no cambiaron
SELECT loyalty_number, available_points
FROM customer_loyalty_history
WHERE loyalty_number = ______;  -- Complete: mismo cliente
```

**Opción B: Cliente inexistente**

```sql
START TRANSACTION;

-- Intente insertar una transacción para un cliente que NO existe
INSERT INTO redemption_transactions
(loyalty_number, points_used, dollar_value, transaction_date, status)
VALUES (______, 5000, 250.00, CURDATE(), 'COMPLETED');
-- Complete: use un loyalty_number que NO exista en la base (ej: 999999)

-- Esto debe fallar por FOREIGN KEY constraint

ROLLBACK;

-- Verifique que NO se insertó el registro
SELECT COUNT(*) AS registros
FROM redemption_transactions
WHERE loyalty_number = ______;  -- Complete: mismo número inexistente (debe ser 0)
```

**Evidencia solicitada:**

- Captura del estado ANTES del intento
- Captura de la transacción con el error (incluya mensajes de error si los hay)
- Captura del comando `ROLLBACK;`
- Captura del estado DESPUÉS (debe ser idéntico al estado ANTES)
- Explicación breve: ¿Por qué falló la transacción? ¿Cómo ROLLBACK protege la integridad?

## FASE 2: Logging y Persistencia (2.0 puntos)

### a) Identifique parámetros fundamentales del motor InnoDB (1.0 punto)

**Paso 1:** Ejecute los siguientes comandos y documente los resultados con capturas de pantalla:

```sql
SHOW VARIABLES LIKE 'innodb_log%';
SHOW ENGINE INNODB STATUS;
```

**Paso 2:** Responda las siguientes preguntas conceptuales (3-5 oraciones cada una):

**Pregunta 1:** ¿Qué es el **redo log** y qué registra?

**Pregunta 2:** ¿En qué momento se escribe en el redo log durante la transacción?

**Pregunta 3:** ¿Qué sucedería si el servidor se cae después del UPDATE pero antes del COMMIT?

---

### b) Recuperación ante Fallos - Conceptos Básicos (1.0 punto)

Responda las siguientes preguntas en 3-5 oraciones cada una. **No necesita conocer detalles técnicos de implementación**, solo los conceptos fundamentales.

**Pregunta 1 (0.25 puntos):** ¿Por qué MySQL necesita un redo log?

**Pregunta 2 (0.25 puntos):** ¿Qué sucede con transacciones COMMITTED cuando hay un crash?

**Pregunta 3 (0.25 puntos):** ¿Qué sucede con transacciones NO COMMITTED cuando hay un crash?

**Pregunta 4 (0.25 puntos):** ¿Qué es un checkpoint y por qué es útil?

> **Ayuda:** Piensa en términos de:
> - **Durabilidad** (D de ACID): ¿Cómo se garantiza que los datos confirmados no se pierdan?
> - **Atomicidad** (A de ACID): ¿Cómo se garantiza que las transacciones incompletas se deshagan?
> - **Analogía útil:** Un checkpoint es como "guardar el progreso" en un videojuego

## FASE 3: Optimización y EXPLAIN ANALYZE (2.0 puntos)

Se da la consulta que busca la actividad de vuelos de clientes de nivel Aurora en Ontario durante 2018:

```sql
SELECT clh.loyalty_number,
       clh.city,
       clh.clv,
       cfa.total_flights,
       cfa.distance,
       cfa.points_accumulated
FROM customer_flight_activity cfa
JOIN customer_loyalty_history clh ON clh.loyalty_number = cfa.loyalty_number
WHERE clh.loyalty_card = 'Aurora'
  AND clh.province = 'Ontario'
  AND cfa.year = 2018
  AND cfa.total_flights > 0
ORDER BY cfa.distance DESC;
```

### a) Ejecute y analice la consulta SIN índices (1.0 punto)

**Paso 1:** Ejecute el siguiente comando:

```sql
EXPLAIN ANALYZE
SELECT clh.loyalty_number,
       clh.city,
       clh.clv,
       cfa.total_flights,
       cfa.distance,
       cfa.points_accumulated
FROM customer_flight_activity cfa
JOIN customer_loyalty_history clh ON clh.loyalty_number = cfa.loyalty_number
WHERE clh.loyalty_card = 'Aurora'
  AND clh.province = 'Ontario'
  AND cfa.year = 2018
  AND cfa.total_flights > 0
ORDER BY cfa.distance DESC;
```

**Paso 2:** Responda estas preguntas SIMPLES usando la salida de EXPLAIN ANALYZE:

> **Ayuda:** Busca en la salida las palabras clave que están entre comillas.

**Pregunta 1 (0.25 puntos):** ¿Hay un "Table scan"? ¿En qué tabla?

**Pregunta 2 (0.25 puntos):** ¿Qué índice se usa en la tabla `customer_flight_activity` (cfa)?

**Pregunta 3 (0.25 puntos):** ¿Cuánto tiempo tomó la consulta? (mira el valor de "actual time")

**Pregunta 4 (0.25 puntos):** ¿Cuál es el problema principal que identificas?

> **Pista:** Un "Table scan" significa que MySQL está leyendo TODAS las filas de la tabla, en vez de usar un índice para ir directamente a las filas que necesita.

### b) Cree un índice y compare la mejora (1.0 punto)

**Paso 1:** Cree el índice que soluciona el problema del "Table scan"

> ¿Recuerdas el problema de la Fase 3a? El "Table scan" en la tabla `customer_loyalty_history`.

```sql
-- Crea un índice en las DOS columnas que usamos en el filtro
CREATE INDEX ______  -- Complete: nombre descriptivo (ej: idx_loyalty_card_province)
ON customer_loyalty_history (______, ______);
-- Complete: las dos columnas del filtro WHERE
```

> **Ayuda:** La consulta filtra por `loyalty_card = 'Aurora'` AND `province = 'Ontario'`
>
> **¿Por qué un índice COMPUESTO (dos columnas)?**
> Porque filtramos por AMBAS condiciones a la vez. Un índice compuesto permite buscar por las dos columnas simultáneamente.

**Paso 2:** Vuelva a ejecutar la MISMA consulta del ejercicio 3a con `EXPLAIN ANALYZE`

**Paso 3:** Responda estas preguntas comparando ANTES y DESPUÉS:

**Pregunta 1 (0.25 puntos):** ¿Se eliminó el "Table scan"? ¿Qué dice ahora en su lugar?

**Pregunta 2 (0.25 puntos):** ¿Cuántas filas lee ahora en la tabla `clh` (customer_loyalty_history)?

**Pregunta 3 (0.25 puntos):** ¿Mejoró el tiempo de ejecución? Muestra una tabla comparativa:

| Métrica | ANTES | DESPUÉS | Mejora |
|---------|-------|---------|--------|
| Tiempo total (actual time) | | | |
| Filas leídas en clh | | | |

**Pregunta 4 (0.25 puntos):** ¿Por qué funciona mejor un índice COMPUESTO en este caso?

> **Pista:** Piensa en cómo MySQL puede buscar directamente las filas que cumplen AMBAS condiciones (Aurora + Ontario) en un solo paso, en vez de leer todas las filas y luego filtrar.

---

## FORMATO DE ENTREGA

Debes entregar **2 archivos**:

**1. Archivo SQL:** `Apellido_Nombre_GA14.sql`

- Fase 1: Código SQL completo de la transacción exitosa y la transacción con ROLLBACK
- Fase 3: Consulta original, comando EXPLAIN ANALYZE, creación del índice y consulta optimizada

**2. Archivo PDF:** `Apellido_Nombre_GA14.pdf`

- **Portada:** Nombre completo, fecha, matrícula
- **Fase 1:** Capturas de pantalla que evidencien:
  - Puntos disponibles ANTES de la transacción
  - Transacción exitosa ejecutada (código completo)
  - Puntos disponibles DESPUÉS de la transacción
  - Registro en `redemption_transactions`
  - Registro actualizado en `customer_flight_activity`
  - Caso de ROLLBACK completo (antes, durante y después)
  - Explicación de por qué falló y cómo ROLLBACK protege la integridad
- **Fase 2:**
  - Capturas de `SHOW VARIABLES LIKE 'innodb_log%'`
  - Respuestas a las 3 preguntas sobre redo log (Parte a)
  - Respuestas a las 4 preguntas sobre crash recovery (Parte b)
- **Fase 3:**
  - Captura de EXPLAIN ANALYZE ANTES de crear el índice
  - Respuestas a las 4 preguntas de análisis (Parte a)
  - Comando CREATE INDEX ejecutado
  - Captura de EXPLAIN ANALYZE DESPUÉS de crear el índice
  - Respuestas a las 4 preguntas comparativas (Parte b)

Entrega al finalizar la evaluación

## Recomendaciones

- Revisa los contenidos de las semanas 1-4 antes de la evaluación
- Familiarízate con el esquema de la base de datos `airline_loyalty_db`
- **Fase 1:** Verifica que el cliente tenga puntos suficientes antes de intentar la transacción
- **Fase 2:** Relaciona el redo log con la Durabilidad (D de ACID) y piensa en términos de "guardar el progreso"
- **Fase 3:** Busca las palabras clave "Table scan" e "Index lookup" en la salida de EXPLAIN ANALYZE
- Lee las **pistas y ayudas** en cada fase - están diseñadas para guiarte
- Guarda tu trabajo frecuentemente
- Si tienes dudas sobre un espacio en blanco, lee el contexto y las ayudas proporcionadas

---

**FIN DE LA EVALUACIÓN**
