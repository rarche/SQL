DROP DATABASE IF EXISTS rarvk;
CREATE DATABASE rarvk;
USE rarvk;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	email VARCHAR(100) UNIQUE,
	password_users VARCHAR(50),
	phone BIGINT UNSIGNED UNIQUE,
	INDEX ind_full_name(firstname, lastname)
);


# Создание таблицы со связью 1 к 1
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	sex CHAR(1),
	town VARCHAR(100),
	created_at DATETIME DEFAULT NOW()
);

# добавление внешнего ключа
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_user_id
FOREIGN KEY (user_id) REFERENCES users(id);

#добавление поля в УЖЕ существующую таблицу
ALTER TABLE profiles ADD COLUMN birthday DATETIME;

#изменение параметров уже существующего поля
ALTER TABLE profiles MODIFY COLUMN birthday DATE;
ALTER TABLE profiles RENAME COLUMN birthday TO day_of_birth;

#удаление колонки в существующей таблице
ALTER TABLE profiles DROP COLUMN day_of_birth;

#создание таблицы со связью один ко многим
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (from_user_id) REFERENCES users(id),
	FOREIGN KEY (to_user_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initial_user_id BIGINT UNSIGNED NOT NULL,
	target_user_id BIGINT UNSIGNED NOT NULL,
	status ENUM('requested','approved','declined','unfriended'), -- ENUM - перечисление строго определенного количества объектов
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	PRIMARY KEY (initial_user_id, target_user_id),  -- создаем уникальный составной первичный ключ из пары Id юзеров
	FOREIGN KEY (initial_user_id) REFERENCES users(id),
	FOREIGN KEY (target_user_id) REFERENCES users(id),
	CHECK (initial_user_id != target_user_id) -- проверка, чтобы нельзя было послать запрос самому себе
);

# ALTER TABLE friend_requests
# ADD CHECK (initial_user_id <> target_user_id) -- та же проверка, но добавляемая в уже сущ. таблицу

DROP TABLE IF EXISTS communities;
CREATE TABLE communities (
	id SERIAL,
	name VARCHAR(255),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	
	INDEX(name),
	FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

# создание промежуточной таблицы для хранения информации о том, сколько юзеров состоит в группах, и сколько групп у каждого из юзера 
# создаем такую таблицу, поскольку не можем добавлять ссылки юзеров/сообщества в соответствующие таблица (так получим по 1 юзеру в каждом сообществе/1 сообществу на каждого юзера)
# данная таблица реализует связь M x M - многие ко многим.
DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities (
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (user_id, community_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (community_id) REFERENCES communities(id)
);


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
	name VARCHAR(255) -- 'text', 'video', 'music', 'image'
);

# таблица для ленты новостей
DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	media_type_id BIGINT UNSIGNED NOT NULL,
	user_message VARCHAR(255),
	filename VARCHAR(255),
	metadata JSON, -- информация, прикрепленная к посту пользователя 
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	#данные поля необходимо сделать внешними ключами, еще один способ это сделать - через ERD диаграмму.
	created_at DATETIME DEFAULT NOW()
);

DROP TABLE IF EXISTS stickerpacks;
CREATE TABLE stickerpacks(
	id SERIAL,
	name VARCHAR(255),
	author_id BIGINT UNSIGNED NOT NULL,
	price TINYINT,
	descrption VARCHAR(255),
	created_at DATE,
	
	INDEX (name),
	FOREIGN KEY (author_id) REFERENCES users(id)
);



