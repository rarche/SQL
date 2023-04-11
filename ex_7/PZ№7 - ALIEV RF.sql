
/*Сложные запросы»*/

DROP DATABASE IF EXISTS shop_r;
CREATE DATABASE shop_r;
USE shop_r;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
	id SERIAL AUTO_INCREMENT PRIMARY KEY,
	catalog_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(255) COMMENT 'Наименование товара',
	
	FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
);

INSERT INTO products(catalog_id,name) VALUES
	(1,'processor-1'),
	(1,'processor-2'),
	(1,'processor-3'),
	(1,'processor-4'),
	(3,'videocard-1'),
	(3,'videocard-2'),
	(3,'videocard-3');
 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL AUTO_INCREMENT PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	product_id BIGINT UNSIGNED NOT NULL,
	 
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO orders(user_id,product_id) VALUES
	(1,3),
	(2,3),
	(1,1),
	(5,5),
	(2,4);
	

# 1.Составьте список пользователей users, которые
# осуществили хотя бы один заказ orders в интернет магазине.

SELECT name FROM users JOIN orders ON users.id = orders.user_id GROUP BY name;

# 2.Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT products.name AS product_name, catalogs.name AS catalog_name FROM products JOIN catalogs ON products.catalog_id = catalogs.id;

# 3.Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. 
# Выведите список рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	id SERIAL AUTO_INCREMENT PRIMARY KEY,
	town_from CHAR(30),
	town_to CHAR(30)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	label VARCHAR(100),
	name CHAR(30)
);

INSERT INTO flights(town_from, town_to) VALUES
	('moscow','omsk'),
	('novgorod','kazan'),
	('irkutsk','moscow'),
	('omsk','irkutsk'),
	('moscow','kazan');
	
INSERT INTO cities VALUES
	('moscow','Москва'),
	('novgorod','Новгород'),
	('irkutsk','Иркутск'),
	('omsk','Омск'),
	('kazan','Казань');

SELECT @@sql_mode; -- ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
 SET @@sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP TABLE IF EXISTS flights_from_rus;
CREATE TABLE flights_from_rus (
 	id SERIAL AUTO_INCREMENT PRIMARY KEY,
	town_from CHAR(30)
);

DROP TABLE IF EXISTS flights_to_rus;
CREATE TABLE flights_to_rus (
 	id SERIAL AUTO_INCREMENT PRIMARY KEY,
	town_to CHAR(30)
);

INSERT INTO flights_from_rus (SELECT flights.id,cities.name FROM flights JOIN cities ON flights.town_from = cities.label
GROUP BY flights.id
ORDER BY flights.id
LIMIT 5);

INSERT INTO flights_to_rus (SELECT flights.id,cities.name FROM flights JOIN cities ON flights.town_to = cities.label
GROUP BY flights.id
ORDER BY flights.id
LIMIT 5);

SELECT * FROM flights_from_rus JOIN flights_to_rus USING (id);

SELECT * FROM products p 
