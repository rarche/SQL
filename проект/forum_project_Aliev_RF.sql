-- Итоговый проект: база данных для форума онлайн-игры --
/*Данная база данных описывает структуру форума фентезийной игры, в которой игроки могут создавать персонажей,
заводить друзей, обмениваться сообщениями и делиться новостями/прогрессом в игре*/

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
	amount_of_heroes INT UNSIGNED DEFAULT 0,  -- добавим параметр количество героев - для оформления процедуры в дальнейшем
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


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
	name VARCHAR(255)
);

DROP TABLE IF EXISTS news;
CREATE TABLE news(
	id SERIAL AUTO_INCREMENT,
	player_id BIGINT UNSIGNED NOT NULL,
	media_type_id BIGINT UNSIGNED NOT NULL,
	player_message VARCHAR(255),
	filename VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (player_id) REFERENCES players(id),
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

	
DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL AUTO_INCREMENT,
	news_id BIGINT UNSIGNED NOT NULL,
	player_id BIGINT UNSIGNED NOT NULL,
	comment_body VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (news_id) REFERENCES news(id),
	FOREIGN KEY (player_id) REFERENCES players(id)
);

-- процедура на увеличение показателя amount_of_heroes в профиле игрока при создании персонажа;

DROP PROCEDURE IF EXISTS heroes_count;
delimiter //
CREATE PROCEDURE heroes_count (
	pl_id BIGINT UNSIGNED
)
BEGIN
	UPDATE profiles
	SET amount_of_heroes = amount_of_heroes + 1
	WHERE  player_id = pl_id;
END //
delimiter ;

DROP TRIGGER IF EXISTS increase_heroes_count;
delimiter ..
CREATE TRIGGER increase_heroes_count
AFTER INSERT ON heroes
FOR EACH ROW
BEGIN 
	CALL heroes_count(NEW.player_id);
END ..
delimiter ;

	

-- дамп БД --
INSERT INTO players(nickname,email,password_players,phone,birthday_date) VALUES 
	('GoatMeal','@goatmeal.ru','sql-injection',2009931,'12.04.2002'),
	('Robin','@robin.ru','robinisgood',2001231,'14.01.2005'),
	('Trindamir','@trindamir.ru','trindamiri123',1231122,'12.04.2003'),
	('Finest','@finestfine.ru','ssa123zxc',1230011,'13.12.2001'),
	('CowRat','@gotcowrat.ru','cow-or-rat',123221,'12.04.2005'),
	('Bot_1','@bot1.ru','bot_1_text',1122334455,'01.01.2001'),
	('Bot_2','@bot2.ru','bot_2_text',111234123124455,'01.01.2001'),
	('Bot_3','@bot3.ru','bot_3_text',112123231155,'01.01.2001'),
	('Bot_4','@bot4.ru','bot_4_text',112542334455,'01.01.2001'),
	('Bot_5','@bot5.ru','bot_5_text',11444223123455,'01.01.2001'),
	('Bot_6','@bot6.ru','bot_6_text',112099034555,'01.01.2001');


INSERT INTO profiles(player_id,description,b_test,sex) VALUES
	(1,'regular player',0,'m'),
	(2,'unregular player',0,'f'),
	(3,'cool player',1,'m'),
	(4,'fine player',0,'f'),
	(5,'bad player',0,'m'),
	(6,'bot',1,'f'),
	(7,'bot',1,'f'),
	(8,'bot',1,'f'),
	(9,'bot',1,'f'),
	(10,'botr',1,'f'),
	(11,'ebotr',1,'f');

INSERT INTO heroes(player_id,name,lvl,race,class,description,sex) VALUES 
	(1, 'CoolWar',19,'human','warrior','the coolest warrior','m'),
	(2, 'Gendalf',24,'human','wizard','the coolest wizard','m'),
	(2, 'Legolas',19,'elf','archer','the coolest archer','m'),
	(4,'Holy_priestess',25,'elf','priest','savior of lives','f'),
	(4,'JustOrkWithBow',12,'ork','archer','arrowgoBRRR','f'),
	(5, 'MightyOrk',30,'ork','warrior','WAAAAGH','m'),
	(6, 'Simplebot',11,'ork','warrior','WAAAAGH','m'),
	(6, 'Simplebot1',15,'ork','warrior','WAAAAGH','m'),
	(6, 'Simplebot2',12,'ork','warrior','WAAAAGH','m'),
	(7, 'Simplebot3',11,'ork','warrior','WAAAAGH','m'),
	(9, 'Simplebot',11,'ork','warrior','WAAAAGH','m'),
	(9, 'Simplebot',11,'ork','warrior','WAAAAGH','m');
	
INSERT INTO messages(from_player_id,to_player_id,body) VALUES
	(1,2,'nice hero'),
	(2,1,'nice sword'),
	(3,2,'go PVP'),
	(2,3,'i prefer PVE');
	
INSERT INTO friend_requests(initial_player_id,target_player_id,status) VALUES
	(1,2,'requested'),
	(1,5,'approved'),
	(4,1,'declined');
	
INSERT INTO clans(name,description,head_of_clan_id) VALUES 
	('Brotherhood_of_steel','The most brutal clan',2),
	('Rainbow Pony','WAAAAAAAGH',5);
	
INSERT INTO players_clans VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 2),
	(5, 2),
	(6, 2),
	(10,2),
	(9, 1),
	(8, 1),
	(7, 1),
	(11, 2);
	
INSERT INTO media_types VALUES
	(1,'jpg'),
	(2,'mp3'),
	(3,'mp4');

INSERT INTO news(player_id,media_type_id,player_message,filename) VALUES
	(2,1,'finally finish the dange!','dange_completed.jpg'),
	(5,1,'text me, if u have some minerals on sale','take_minerals.jpg');

INSERT INTO comments(news_id,player_id,comment_body) VALUES 
	(1,4,'congrats!'),
	(2,5,'i have some!');
	
	
-- Осуществим запрос на получение выборки имен игроков, состоящих в первом клане и имеющих как минимум 2 персонажей

SELECT p.id,p.nickname  FROM
	players p
	JOIN profiles p2 ON p.id = p2.player_id 
	JOIN players_clans pc ON p.id = pc.player_id
	WHERE pc.clan_id = 1 AND p2.amount_of_heroes >= 2;
	
-- Представления

-- 1.Количество игроков в каждом клане
SELECT @@sql_mode; -- ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
SET @@sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


CREATE VIEW player_in_clan AS
	SELECT c.name, COUNT(*) AS players FROM players_clans pc JOIN clans c ON c.id = pc.clan_id GROUP BY c.name;
	
SELECT * FROM player_in_clan;

-- 2.Количество персонажей у каждого игрока

CREATE VIEW player_heroes AS
	SELECT p2.id , p2.nickname, p.amount_of_heroes FROM players p2
	JOIN profiles p ON p2.id = p.player_id
	ORDER BY p2.id;
	
SELECT * FROM player_heroes;