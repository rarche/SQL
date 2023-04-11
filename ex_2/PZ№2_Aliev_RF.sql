DROP TABLE IF EXISTS stickerpacks_users;
CREATE TABLE stickerpacks_users(
	stickerpack_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (user_id, stickerpack_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (stickerpack_id) REFERENCES stickerpacks(id)
);

DROP TABLE IF EXISTS videos;
CREATE TABLE videos(
	id SERIAL,
	name VARCHAR(255),
	description VARCHAR(255),
	author_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	
	PRIMARY KEY (author_id, name),
	FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL,
	media_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);
