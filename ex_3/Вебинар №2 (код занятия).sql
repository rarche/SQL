-- Итоговый проект: база данных для форума онлайн-игры --

DROP DATABASE IF EXISTS forum;
CREATE DATABASE forum;
USE forum;

DROP TABLE IF EXISTS players;
CREATE TABLE players(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nickname VARCHAR(50),
	email VARCHAR(100) UNIQUE,
	password_players VARCHAR(50),
	phone BIGINT UNSIGNED UNIQUE,
	birthday_date DATETIME DEFAULT NOW(),
	INDEX (nickname)
);

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	player_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	description TEXT,
	b_test BOOL,
	sex CHAR(1),
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (player_id) REFERENCES players(id)
);


DROP TABLE IF EXISTS heroes;
CREATE TABLE  heroes(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	player_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(100),
	lvl TINYINT,
	race ENUM('elf','human','ork','dwarf'),
	class ENUM('warrior','wizard','archer','priest'),
	description TEXT,
	sex CHAR(1),
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (player_id) REFERENCES players(id)
);

	
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL AUTO_INCREMENT,
	from_player_id BIGINT UNSIGNED NOT NULL,
	to_player_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (from_player_id) REFERENCES players(id),
	FOREIGN KEY (to_player_id) REFERENCES players(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initial_player_id BIGINT UNSIGNED NOT NULL,
	target_player_id BIGINT UNSIGNED NOT NULL,
	status ENUM('requested','approved','declined','unfriended'),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	PRIMARY KEY (initial_player_id, target_player_id), 
	FOREIGN KEY (initial_player_id) REFERENCES players(id),
	FOREIGN KEY (target_player_id) REFERENCES players(id),
	CHECK (initial_player_id != target_player_id)
);


DROP TABLE IF EXISTS clans;
CREATE TABLE clans (
	id SERIAL AUTO_INCREMENT,
	name VARCHAR(255),
	description TEXT,
	head_of_clan_id BIGINT UNSIGNED NOT NULL,
	
	INDEX(name),
	FOREIGN KEY (head_of_clan_id) REFERENCES players(id)
);
	

DROP TABLE IF EXISTS players_clans;
CREATE TABLE players_clans (
	player_id BIGINT UNSIGNED NOT NULL,
	clan_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (player_id, clan_id),
	FOREIGN KEY (player_id) REFERENCES players(id),
	FOREIGN KEY (clan_id) REFERENCES clans(id)
);

INSERT INTO players_clans VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 2),
	(5, 2),
	(6, 2)

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
	name VARCHAR(255)
);

DROP TABLE IF EXISTS news;
CREATE TABLE news(
	id SERIAL,
	player_id BIGINT UNSIGNED NOT NULL,
	media_type_id BIGINT UNSIGNED NOT NULL,
	player_message VARCHAR(255),
	filename VARCHAR(255),
	metadata JSON, 
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (player_id) REFERENCES players(id),
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL,
	news_id BIGINT UNSIGNED NOT NULL,
	player_id BIGINT UNSIGNED NOT NULL,
	comment_body VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (news_id) REFERENCES news(id),
	FOREIGN KEY (player_id) REFERENCES players(id)
);


-- дамп БД --
INSERT INTO players(nickname,email,password_players,phone,birthday_date) VALUES 
	('GoatMeal','@goatmeal.ru','sql-injection',2009931,'12.04.2002'),
	('Robin','@robin.ru','robinisgood',2001231,'14.01.2005'),
	('Trindamir','@trindamir.ru','trindamiri123',1231122,'12.04.2003'),
	('Finest','@finestfine.ru','ssa123zxc',1230011,'13.12.2001'),
	('CowRat','@gotcowrat.ru','cow-or-rat',123221,'12.04.2005'),
	('Brotherofsteel','@steelcool.ru','123ksks02',123411,'12.04.2003')


INSERT INTO profiles(player_id,description,b_test,sex) VALUES
	(1,'regular player',0,'m'),
	(2,'unregular player',0,'f'),
	(3,'cool player',1,'m'),
	(4,'fine player',0,'f'),
	(5,'bad player',0,'m'),
	(6,'evil player',1,'f')

INSERT INTO heroes(player_id,name,lvl,race,class,description,sex) VALUES 
	(1, 'CoolWar',19,'human','warrior','the coolest warrior','m'),
	(2, 'Gendalf',24,'human','wizard','the coolest wizard','m'),
	(2, 'Legolas',19,'elf','archer','the coolest archer','m'),
	(4,'Holy_priestess',25,'elf','priest','savior of lives','f'),
	(5, 'MightyOrk',30,'ork','warrior','WAAAAGH','m')
	
INSERT INTO messages(from_player_id,to_player_id,body) VALUES
	(1,2,'nice hero'),
	(2,1,'nice sword'),
	(3,2,'go PVP'),
	(2,3,'i prefer PVE')
	
INSERT INTO friend_requests(initial_player_id,target_player_id,status) VALUES
	(1,2,'requested'),
	(1,5,'approved'),
	(4,1,'declined')
	
INSERT INTO clans(name,description,head_of_clan_id) VALUES 
	('Brotherhood_of_steel','The most brutal clan',2),
	('Rainbow Pony','WAAAAAAAGH',5)
	
INSERT INTO players_clans VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 2),
	(5, 2),
	(6, 2)