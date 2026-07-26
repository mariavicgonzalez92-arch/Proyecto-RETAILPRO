-- ══════════════════════════════════════════════════════════════════════════
-- RetailPro — Pre-entrega: Consultas SQL de negocio
-- Título: Extrayendo métricas clave con SQL
-- Archivo: m4_consultas_negocio.sql
-- Base de Datos: Ventas_Tech_DB
-- Tabla: ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- Motor: SQL Server (T-SQL)
-- ══════════════════════════════════════════════════════════════════════════


-- ──────────────────────────────────────────────────────────────────────────
-- CONSULTA 1: Resumen ejecutivo mensual
-- Objetivo: Total facturado, cantidad de pedidos y ticket promedio agrupados por mes.
-- ──────────────────────────────────────────────────────────────────────────

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- ──────────────────────────────────────────────────────────────────────────
-- CONSULTA 2: Ranking de productos (Top 5)
-- Objetivo: Top 5 de id_producto por total facturado, mostrando unidades vendidas.
-- ──────────────────────────────────────────────────────────────────────────

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- ──────────────────────────────────────────────────────────────────────────
-- CONSULTA 3: Clientes recurrentes
-- Objetivo: id_cliente con más de 1 pedido, cantidad de pedidos y total gastado.
-- ──────────────────────────────────────────────────────────────────────────

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ──────────────────────────────────────────────────────────────────────────
-- CONSULTA 4: Meses por encima/por debajo del promedio
-- Objetivo: Total facturado por mes con etiqueta comparativa respecto al promedio general.
-- ──────────────────────────────────────────────────────────────────────────

WITH facturacion_mensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_mes
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
promedio_general AS (
    SELECT AVG(total_mes) AS promedio_mensual
    FROM facturacion_mensual
)
SELECT 
    f.mes,
    f.total_mes AS total_facturado,
    CASE 
        WHEN f.total_mes >= p.promedio_mensual THEN 'Por encima'
        ELSE 'Por debajo'
    END AS relacion_promedio
FROM facturacion_mensual f
CROSS JOIN promedio_general p
ORDER BY f.mes;


-- ══════════════════════════════════════════════════════════════════════════
-- BLOQUE DE CIERRE: Hallazgos Clave de Negocio
-- ══════════════════════════════════════════════════════════════════════════
/*
HALLAZGOS CONCRETOS DE LA EXPLORACIÓN DE DATOS:

1. Concentración de ventas en Producto Top: El producto con mayor facturación concentra una porción significativa del volumen total de ingresos, consolidándose como el principal motor de ventas del catálogo.
2. Comportamiento de Clientes Recurrentes: Existe un segmento clave de clientes con más de un pedido que registran un gasto acumulado sustancialmente superior a la media, representando la mayor oportunidad de fidelización.
3. Estacionalidad Mensual de Ingresos: Al comparar la facturación mensual contra el promedio general, se identifican meses pico con alto volumen de pedidos y ticket promedio elevado que impulsan el resultado general.
*/
