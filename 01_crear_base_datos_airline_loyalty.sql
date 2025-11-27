-- ============================================================================
-- SCRIPT: Creación de Base de Datos - Programa de Lealtad de Aerolínea
-- CURSO: Sistemas de Gestión de Bases de Datos (SGBD-ASC)
-- SEMANA: 05
-- DESCRIPCIÓN: Script para crear la base de datos y las tablas del programa
--              de lealtad de aerolínea canadiense
-- AUTOR: Curso SGBD-ASC
-- FECHA: 2025
-- ============================================================================

-- Eliminar la base de datos si existe (para pruebas)
DROP DATABASE IF EXISTS airline_loyalty_db;

-- Crear la base de datos
CREATE DATABASE airline_loyalty_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE airline_loyalty_db;

-- ============================================================================
-- TABLA: calendar
-- DESCRIPCIÓN: Tabla dimensional de calendario para análisis temporal
-- PERÍODO: 2012-01-01 hasta 2018-12-31
-- ============================================================================
CREATE TABLE calendar (
    date_id DATE PRIMARY KEY COMMENT 'Fecha específica',
    start_of_year DATE NOT NULL COMMENT 'Inicio del año',
    start_of_quarter DATE NOT NULL COMMENT 'Inicio del trimestre',
    start_of_month DATE NOT NULL COMMENT 'Inicio del mes',
    year_num INT NOT NULL COMMENT 'Año numérico',
    quarter_num INT NOT NULL COMMENT 'Trimestre (1-4)',
    month_num INT NOT NULL COMMENT 'Mes (1-12)',
    day_of_week VARCHAR(20) COMMENT 'Día de la semana',
    INDEX idx_year (year_num),
    INDEX idx_quarter (start_of_quarter),
    INDEX idx_month (start_of_month)
) ENGINE=InnoDB COMMENT='Tabla dimensional de calendario';

-- ============================================================================
-- TABLA: customer_loyalty_history
-- DESCRIPCIÓN: Información demográfica y de membresía de clientes
-- REGISTROS: ~16,739 clientes únicos
-- ============================================================================
CREATE TABLE customer_loyalty_history (
    loyalty_number INT PRIMARY KEY COMMENT 'Número único de lealtad del cliente',
    country VARCHAR(50) NOT NULL COMMENT 'País de residencia',
    province VARCHAR(50) COMMENT 'Provincia de residencia',
    city VARCHAR(100) COMMENT 'Ciudad de residencia',
    postal_code VARCHAR(20) COMMENT 'Código postal',
    gender ENUM('Male', 'Female') COMMENT 'Género',
    education VARCHAR(50) COMMENT 'Nivel educativo',
    salary DECIMAL(10,2) COMMENT 'Ingreso anual',
    marital_status ENUM('Single', 'Married', 'Divorced') COMMENT 'Estado civil',
    loyalty_card ENUM('Star', 'Nova', 'Aurora') NOT NULL COMMENT 'Nivel de tarjeta',
    clv DECIMAL(10,2) NOT NULL COMMENT 'Customer Lifetime Value',
    enrollment_type VARCHAR(50) NOT NULL COMMENT 'Tipo de inscripción',
    enrollment_year INT NOT NULL COMMENT 'Año de inscripción',
    enrollment_month INT NOT NULL COMMENT 'Mes de inscripción',
    cancellation_year INT COMMENT 'Año de cancelación',
    cancellation_month INT COMMENT 'Mes de cancelación',
    INDEX idx_loyalty_card (loyalty_card),
    INDEX idx_province (province),
    INDEX idx_enrollment (enrollment_year, enrollment_month),
    INDEX idx_clv (clv),
    INDEX idx_cancellation (cancellation_year, cancellation_month)
) ENGINE=InnoDB COMMENT='Historial de clientes del programa de lealtad';

-- ============================================================================
-- TABLA: customer_flight_activity
-- DESCRIPCIÓN: Actividad mensual de vuelos por cliente
-- REGISTROS: ~392,938 registros de actividad
-- ============================================================================
CREATE TABLE customer_flight_activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID único de actividad',
    loyalty_number INT NOT NULL COMMENT 'Número de lealtad del cliente',
    year INT NOT NULL COMMENT 'Año del período',
    month INT NOT NULL COMMENT 'Mes del período',
    total_flights INT NOT NULL DEFAULT 0 COMMENT 'Total de vuelos reservados',
    distance INT NOT NULL DEFAULT 0 COMMENT 'Distancia recorrida en km',
    points_accumulated INT NOT NULL DEFAULT 0 COMMENT 'Puntos acumulados',
    points_redeemed INT NOT NULL DEFAULT 0 COMMENT 'Puntos canjeados',
    dollar_cost_points_redeemed DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Valor en CAD de puntos canjeados',
    FOREIGN KEY (loyalty_number) REFERENCES customer_loyalty_history(loyalty_number)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY uk_customer_period (loyalty_number, year, month),
    INDEX idx_year_month (year, month),
    INDEX idx_total_flights (total_flights),
    INDEX idx_points_accumulated (points_accumulated),
    INDEX idx_points_redeemed (points_redeemed)
) ENGINE=InnoDB COMMENT='Actividad mensual de vuelos por cliente';

-- ============================================================================
-- VISTAS ÚTILES PARA ANÁLISIS
-- ============================================================================

-- Vista: Resumen de clientes activos
CREATE OR REPLACE VIEW v_active_customers AS
SELECT 
    clh.loyalty_number,
    clh.loyalty_card,
    clh.province,
    clh.city,
    clh.clv,
    clh.enrollment_year,
    COUNT(cfa.activity_id) as total_activity_records,
    SUM(cfa.total_flights) as lifetime_flights,
    SUM(cfa.distance) as lifetime_distance,
    SUM(cfa.points_accumulated) as lifetime_points_accumulated,
    SUM(cfa.points_redeemed) as lifetime_points_redeemed
FROM customer_loyalty_history clh
LEFT JOIN customer_flight_activity cfa ON clh.loyalty_number = cfa.loyalty_number
WHERE clh.cancellation_year IS NULL
GROUP BY clh.loyalty_number, clh.loyalty_card, clh.province, clh.city, 
         clh.clv, clh.enrollment_year;

-- Vista: Actividad mensual agregada
CREATE OR REPLACE VIEW v_monthly_activity_summary AS
SELECT 
    cfa.year,
    cfa.month,
    COUNT(DISTINCT cfa.loyalty_number) as active_customers,
    SUM(cfa.total_flights) as total_flights,
    SUM(cfa.distance) as total_distance,
    SUM(cfa.points_accumulated) as total_points_accumulated,
    SUM(cfa.points_redeemed) as total_points_redeemed,
    SUM(cfa.dollar_cost_points_redeemed) as total_dollar_cost
FROM customer_flight_activity cfa
GROUP BY cfa.year, cfa.month
ORDER BY cfa.year, cfa.month;

-- Vista: Segmentación por nivel de tarjeta
CREATE OR REPLACE VIEW v_loyalty_card_segments AS
SELECT 
    clh.loyalty_card,
    COUNT(DISTINCT clh.loyalty_number) as customer_count,
    AVG(clh.clv) as avg_clv,
    AVG(clh.salary) as avg_salary,
    SUM(cfa.total_flights) as total_flights,
    SUM(cfa.points_accumulated) as total_points_accumulated
FROM customer_loyalty_history clh
LEFT JOIN customer_flight_activity cfa ON clh.loyalty_number = cfa.loyalty_number
GROUP BY clh.loyalty_card;

-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA
-- ============================================================================
SHOW TABLES;

SELECT 'Base de datos airline_loyalty_db creada exitosamente' AS status;
