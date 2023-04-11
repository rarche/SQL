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

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

DROP TABLE IF EXISTS products;
CREATE TABLE products  (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название продукта',
  catalog_id BIGINT UNSIGNED NOT NULL,
  
  FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
) COMMENT = 'Продукты интернет-магазина';

-- Задание 1
-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs
-- и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор
-- первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE logs(
	date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
	table_name VARCHAR(255),
	table_id INT UNSIGNED NOT NULL,
	name VARCHAR(255)
) ENGINE ARCHIVE;


DROP PROCEDURE IF EXISTS table_logs;
delimiter //
CREATE PROCEDURE table_logs (
	t_name VARCHAR(255),
	t_id INT,
	n VARCHAR(255)
)
BEGIN
	INSERT INTO logs (table_name,table_id,name) VALUES (t_name,t_id,n);
END //
delimiter ;

DROP TRIGGER IF EXISTS logs_catalogs;
delimiter ..
CREATE TRIGGER logs_catalogs
AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	CALL table_logs('catalogs',NEW.id,NEW.name);
END ..
delimiter ;
	

DROP TRIGGER IF EXISTS logs_users;
delimiter // 
CREATE TRIGGER logs_users
AFTER INSERT ON users
FOR EACH ROW
BEGIN 
	CALL table_logs('users',NEW.id,NEW.name);
END //
delimiter ;

DROP TRIGGER IF EXISTS logs_products;
delimiter ..
CREATE TRIGGER logs_products
AFTER INSERT ON products
FOR EACH ROW
BEGIN
	CALL table_logs('products',NEW.id,NEW.name);
END ..
delimiter ;


INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');


INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');
 
 
 SELECT * FROM logs