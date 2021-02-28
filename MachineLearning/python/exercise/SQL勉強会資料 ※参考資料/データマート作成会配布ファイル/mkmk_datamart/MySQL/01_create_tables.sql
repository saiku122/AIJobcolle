/*テーブルを作成するSQL一覧*/

CREATE TABLE users
(
    user_id integer NOT NULL,
    install_at timestamp NOT NULL,
    gender varchar(6) NOT NULL,
    PRIMARY KEY (user_id)
);


CREATE TABLE purchase
(
    user_id integer NOT NULL,
    created_at timestamp NOT NULL
);


CREATE TABLE quests
(
    user_id integer NOT NULL,
    started_at timestamp NOT NULL,
    difficulty varchar(8) NOT NULL
);




