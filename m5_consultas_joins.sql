-- ════════════════════════════════════════════════════════════════════════
-- RetailPro — Pre-entrega M5: Consultas con JOINs para el proyecto
-- Título: Cruzando tablas para enriquecer el análisis
-- ════════════════════════════════════════════════════════════════════════

-- ── CONSULTA 1: Vista base del proyecto (INNER JOIN) ───────────────────
-- Combina ventas, clientes, productos y territorios para Power BI.
-- Fuente principal de datos enriquecida con datos demográficos y de producto.

SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS cliente_nombre,
    c.segmento,
    t.region,
    p.nombre_producto,
    p.categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes c ON v.cliente_id = c.cliente_id
INNER JOIN productos p ON v.producto_id = p.producto_id
INNER JOIN territorios t ON c.territorio_id = t.territorio_id;


-- ── CONSULTA 2: Clientes sin ventas (LEFT JOIN) ────────────────────────
-- Identifica clientes registrados en el CRM que aún no realizaron ninguna compra.

SELECT 
    c.nombre AS cliente_nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL;


-- ── CONSULTA 3: Productos sin ventas (LEFT JOIN) ───────────────────────
-- Identifica artículos del catálogo que no tienen movimiento de stock.

SELECT 
    p.nombre_producto,
    p.categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL;


-- ── CONSULTA 4: Consolidado por canal (UNION ALL) ──────────────────────
-- Consolida ventas Online y Presenciales agregando la etiqueta de origen
-- y calculando el total recaudado y la cantidad de operaciones por canal.

SELECT 
    canal,
    COUNT(*) AS total_transacciones,
    SUM(cantidad * precio_unitario) AS total_recaudado
FROM (
    SELECT cliente_id, producto_id, cantidad, precio_unitario, 'Online' AS canal
    FROM ventas_online
    
    UNION ALL
    
    SELECT cliente_id, producto_id, cantidad, precio_unitario, 'Presencial' AS canal
    FROM ventas_presencial
) AS ventas_consolidadas
GROUP BY canal;
