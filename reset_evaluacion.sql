-- ============================================================================
-- RESET DE LA BASE DE DATOS
-- ============================================================================
-- Este script restaura la base de datos al estado inicial de la evaluación.
-- Úsalo si necesitas reiniciar después de un error o para hacer pruebas nuevamente.

USE airline_loyalty_db;

-- 1. Restaurar puntos del cliente de prueba
-- Nota: Ajusta el valor de available_points según los datos originales de tu cliente
UPDATE customer_loyalty_history
SET available_points = (
    SELECT SUM(points_accumulated) - SUM(points_redeemed)
    FROM customer_flight_activity
    WHERE loyalty_number = 100018
)
WHERE loyalty_number = 100018;

-- 2. Limpiar transacciones de prueba
TRUNCATE TABLE redemption_transactions;

-- 3. Restaurar actividad del cliente
UPDATE customer_flight_activity
SET points_redeemed = 0,
    dollar_cost_points_redeemed = 0.00
WHERE loyalty_number = 100018
  AND year = 2018
  AND month = 12;

-- 4. Eliminar índices de Fase 3 y 4 (si existen)
DROP INDEX IF EXISTS idx_loyalty_card_province ON customer_loyalty_history;
DROP INDEX IF EXISTS idx_year_flights ON customer_flight_activity;
DROP INDEX IF EXISTS idx_marketing_aurora_active ON customer_loyalty_history;
DROP INDEX IF EXISTS idx_activity_date ON customer_flight_activity;
DROP INDEX IF EXISTS idx_finanzas_reporte_mensual ON customer_flight_activity;
DROP INDEX IF EXISTS idx_province_lookup ON customer_loyalty_history;
DROP INDEX IF EXISTS idx_servicio_cliente_historial ON customer_flight_activity;

-- 5. Verificar que el reset fue exitoso
SELECT
    loyalty_number,
    available_points as puntos_actuales
FROM customer_loyalty_history
WHERE loyalty_number = 100018;
-- Debe mostrar los puntos restaurados

SELECT COUNT(*) as transacciones FROM redemption_transactions;
-- Debe mostrar: 0

SELECT
    points_redeemed,
    dollar_cost_points_redeemed
FROM customer_flight_activity
WHERE loyalty_number = 100018
  AND year = 2018
  AND month = 12;
-- Debe mostrar: 0 y 0.00

-- ============================================================================
-- RESET COMPLETADO
-- ============================================================================
