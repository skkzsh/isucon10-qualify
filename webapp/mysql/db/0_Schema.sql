DROP DATABASE IF EXISTS isuumo;
CREATE DATABASE isuumo;

DROP TABLE IF EXISTS isuumo.estate;
DROP TABLE IF EXISTS isuumo.chair;

CREATE TABLE isuumo.estate
(
    id          INTEGER             NOT NULL PRIMARY KEY,
    name        VARCHAR(64)         NOT NULL,
    description VARCHAR(4096)       NOT NULL,
    thumbnail   VARCHAR(128)        NOT NULL,
    address     VARCHAR(128)        NOT NULL,
    latitude    DOUBLE PRECISION    NOT NULL,
    longitude   DOUBLE PRECISION    NOT NULL,
    rent        INTEGER             NOT NULL,
    door_height INTEGER             NOT NULL,
    door_width  INTEGER             NOT NULL,
    features    VARCHAR(64)         NOT NULL,
    popularity  INTEGER             NOT NULL,
    nega_popularity  INTEGER AS (-popularity) STORED NOT NULL, -- MySQL 8でないと index desc が使えないため
    location   POINT AS (POINT(latitude, longitude)) STORED NOT NULL -- spatial index を貼るため
);

CREATE INDEX idx_rent_id ON isuumo.estate (rent, id);
CREATE INDEX idx_nega_popularity_id ON isuumo.estate (nega_popularity ASC, id ASC);
CREATE SPATIAL INDEX idx_spatial ON isuumo.estate (location);
CREATE INDEX idx_rent_height_width ON isuumo.estate (rent, door_height, door_width);
-- CREATE INDEX idx_estate_search ON estate (door_height, door_width, rent, nega_popularity, id);

CREATE TABLE isuumo.chair
(
    id          INTEGER         NOT NULL PRIMARY KEY,
    name        VARCHAR(64)     NOT NULL,
    description VARCHAR(4096)   NOT NULL,
    thumbnail   VARCHAR(128)    NOT NULL,
    price       INTEGER         NOT NULL,
    height      INTEGER         NOT NULL,
    width       INTEGER         NOT NULL,
    depth       INTEGER         NOT NULL,
    color       VARCHAR(64)     NOT NULL,
    features    VARCHAR(64)     NOT NULL,
    kind        VARCHAR(64)     NOT NULL,
    popularity  INTEGER         NOT NULL,
    stock       INTEGER         NOT NULL
);

CREATE INDEX idx_price_id ON isuumo.chair (price, id);
