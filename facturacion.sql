USE facturacion;

-- Parte 1

-- Pregunta 1
-- ¿Cuántos registros existen en la tabla de clientes?
SELECT COUNT(*) AS 'Cantidad de Clientes'
FROM customers;

-- Pregunta 2
-- ¿Cuántas facturas hay registradas en total?
SELECT COUNT(*) AS 'Cantidad de Facturas'
FROM invoices;

-- Pregunta 3
-- ¿Cuántos productos diferentes están disponibles?
SELECT COUNT(*) AS 'Cantidad de Productos'
FROM products;

-- Pregunta 4
-- Muestra la estructura de la tabla de detalles de factura (campos y tipos de datos).
DESCRIBE invoice_items;

-- Parte 2

-- Pregunta 5
-- ¿Cuál es el cliente con mayor monto total de compras?
SELECT CONCAT(first_name, ' ' ,last_name) AS Cliente, SUM(ii.amount) AS 'Total en Compras'
FROM customers c INNER JOIN invoices i
ON c.customer_id = i.customer_id 
INNER JOIN invoice_items ii
ON i.invoice_id = ii.invoice_id
GROUP BY c.customer_id, first_name
ORDER BY `Total en Compras` DESC
LIMIT 1;

-- Pregunta 6 --
-- ¿Muestre el top 5 de ciudades que han generado un mayor número de facturas?
SELECT c.city AS Ciudad, COUNT(DISTINCT i.invoice_id) AS 'Cantidad de Facturas'
FROM customers c INNER JOIN invoices i
ON c.customer_id = i.customer_id
GROUP BY city
ORDER BY `Cantidad de Facturas` DESC
LIMIT 5;

-- Pregunta 7
-- ¿Qué categoría de productos concentra el mayor volumen de ventas (en monto total)?
SELECT c.category_name AS Categoría, SUM(ii.amount) AS 'Volumen de Ventas'
FROM invoice_items ii INNER JOIN products p
ON ii.product_id = p.product_id 
INNER JOIN categories c
ON p.category_id = c.category_id
GROUP BY c.category_id, category_name
ORDER BY `Volumen de Ventas` DESC
LIMIT 1;

-- Pregunta 8
-- ¿Cuál es el producto más vendido por cantidad de unidades?
SELECT p.product_name AS Producto, SUM(ii.qty) AS 'Unidades Vendidas'
FROM invoice_items ii INNER JOIN products p
ON ii.product_id = p.product_id 
GROUP BY p.product_id, p.product_name
ORDER BY `Unidades Vendidas` DESC
LIMIT 1;

-- Pregunta 9
-- ¿Cómo ha variado el número de facturas emitidas por año y mes?
SELECT YEAR(invoice_date) AS Año, MONTH(invoice_date) AS Mes, COUNT(DISTINCT invoice_id) AS 'Cantidad de Facturas'
FROM invoices
GROUP BY año, mes;

-- Pregunta 10
-- ¿Cúantos clientes han comprado productos de más de una categoría diferente?
SELECT COUNT(t.customer_id) AS 'Cantidad de Clientes'
FROM (SELECT c.customer_id, COUNT(DISTINCT cc.category_id) AS categorias_distintas
FROM customers c INNER JOIN invoices i
ON c.customer_id = i.customer_id 
INNER JOIN invoice_items ii
ON i.invoice_id = ii.invoice_id
INNER JOIN products p
ON ii.product_id = p.product_id 
INNER JOIN categories cc
ON p.category_id = cc.category_id
GROUP BY c.customer_id
HAVING categorias_distintas > 1) AS t;

-- Parte 3
-- PREGUNTAS PROPIAS

-- ¿Cuáles son los 3 días de la semana con el menor volumen de ventas? 
SELECT DATE_FORMAT(i.invoice_date, '%W') AS Día, SUM(ii.amount) AS 'Volumen de Ventas'
FROM invoice_items ii INNER JOIN invoices i
ON ii.invoice_id = i.invoice_id
GROUP BY Día
ORDER BY `Volumen de Ventas` ASC
LIMIT 3;

-- ¿Cuál es la venta promedio por cada factura por mes y año en los últimos 5 años registrados?
WITH last_five_years AS (
SELECT DISTINCT YEAR(invoice_date) AS Año
FROM invoices
ORDER BY Año DESC
LIMIT 5
)

SELECT Año, Mes, `Promedio por Factura` 
FROM (SELECT YEAR(invoice_date) AS Año, DATE_FORMAT(invoice_date, '%M') AS Mes, ROUND(AVG(t.ventas),2) AS 'Promedio por Factura'
FROM (SELECT invoice_id, SUM(amount) AS ventas
FROM invoice_items
GROUP BY invoice_id) AS t INNER JOIN invoices i
ON t.invoice_id = i.invoice_id
GROUP BY Año, Mes) t
WHERE Año IN (SELECT Año FROM last_five_years)
ORDER BY Año, Mes;

-- ¿Cuáles son las 5 ciudades con el mayor volumen de ventas?
SELECT c.city AS Ciudad, SUM(ii.amount) AS 'Volumen de Ventas'
FROM customers c INNER JOIN invoices i
ON c.customer_id = i.customer_id
INNER JOIN invoice_items ii
ON i.invoice_id = ii.invoice_id
GROUP BY city
ORDER BY `Volumen de Ventas` DESC
LIMIT 5;

-- ¿Qué porcentaje del total de ventas de la empresa representa cada categoría de productos?
SELECT c.category_name AS Categoría, SUM(ii.amount) AS 'Total de Ventas',ROUND(SUM(ii.amount) * 100.00 / (SELECT SUM(amount) FROM invoice_items),2) AS 'Porcentaje de Ventas'
FROM invoice_items ii INNER JOIN products p
ON ii.product_id = p.product_id 
INNER JOIN categories c
ON p.category_id = c.category_id
GROUP BY c.category_id, category_name
ORDER BY `Total de Ventas` DESC;