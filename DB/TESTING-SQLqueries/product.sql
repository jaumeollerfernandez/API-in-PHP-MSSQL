CREATE DATABASE shop;
USE shop;
-- DROP TABLE productos
-- Drop procedure get_products
CREATE TABLE productos (
  nombre VARCHAR(50) NOT NULL,
  precio DECIMAL(10, 2) NOT NULL,
  descripcion TEXT,
  url_imagen VARCHAR(255)
);
USE shop;
INSERT INTO productos (nombre, precio, descripcion, url_imagen)
VALUES
  ('iPhone', 999.99, 'Iphone Pocho me gusta Android', 'https://i.dummyjson.com/data/products/2/1.jpg'),
  ('Alcatel 1734', 1435.99, 'Esto es mejor que el iphone, haceos caso', 'https://i.dummyjson.com/data/products/3/1.jpg'),
  ('Movil e321', 50.99, 'Descripción del producto 3', 'https://i.dummyjson.com/data/products/4/1.jpg'),
	('Samsumg galaxio', 39.99, 'Cual es el tabaco mas caro que hay', 'https://i.dummyjson.com/data/products/5/1.jpg'),
	('Mi moto alpina derrapante', 312339.99, 'Mi moto alpina derrapante', 'https://i.dummyjson.com/data/products/7/1.jpg')

USE shop;
SELECT * FROM productos


CREATE OR ALTER PROCEDURE get_products
AS
BEGIN
	SELECT * FROM productos FOR XML RAW, root('products');
END

EXEC get_products






DROP TABLE carrito_compras
CREATE TABLE carrito_compras(
	price FLOAT,
)


CREATE OR ALTER PROCEDURE insert_compras_carrito @price_carr FLOAT OUTPUT
AS
BEGIN
	INSERT INTO carrito_compras VALUES(@price_carr)

	select 'insert Succes' As message FOR XML RAW, ROOT('Response')
	return 0;
END



EXEC insert_compras_carrito 12.32
SELECT * FROM carrito_compras