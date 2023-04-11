
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
	

# 1.В базе данных shop и sample присутствуют одни  и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. 
# Используйте транзакции.

START TRANSACTION;

INSERT INTO example.users 
SELECT id,name FROM shop.users 
WHERE id = 1
DELETE FROM shop.users WHERE id = 1

COMMIT; # почему то SQL-скрипт не работает целиком - приходится запускать каждый запрос по отдельности

SELECT * FROM example.users


#2. Создайте представление, которое выводит название name товарной позиции 
#из таблицы products и соответствующее название каталога name из таблицы catalogs.

CREATE VIEW product_name AS 
	SELECT p.name AS product_name, c.name AS catalog_name
	FROM products p JOIN catalogs c ON p.catalog_id = c.id; 
	
SELECT * FROM product_name;

#3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разреженные 
#календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17.
# Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует 
# в исходной таблице и 0, если она отсутствует.

DROP TABLE IF EXISTS august_date;
CREATE TABLE august_date (
	created_at DATETIME
)

INSERT INTO august_date VALUES 
	('2018-08-01'), 
	('2016-08-04'), 
	('2018-08-16'),
	('2018-08-17')

SELECT * FROM august_date  ORDER BY created_at;

SELECT 
	time_period.selected_date AS day,
	(SELECT EXISTS(SELECT * FROM august_date  WHERE created_at = day)) AS has_already
FROM
	(SELECT v.* FROM 
		(SELECT ADDDATE('1970-01-01',t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) selected_date FROM
			(SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
		    (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) v
	WHERE selected_date BETWEEN '2018-08-01' AND '2018-08-31') AS time_period;
	
