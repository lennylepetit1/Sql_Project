-- On a 6 tables à créer. Voir readme. 

-- La première pour les athlètes

CREATE TABLE athletes (
    "id" INTEGER, 
    "name" TEXT NOT NULL,
    "sex" TEXT CHECK (sex IN ('M', 'F')),
    PRIMARY KEY("id")
);

INSERT INTO athletes ("id", "name", "sex")
SELECT DISTINCT
    "id",
    "name",
    "sex"
FROM base_de_table;

-- La deuxième pour la table des équipes. teams

CREATE TABLE teams (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "NOC_code" TEXT NOT NULL,
    PRIMARY KEY("id")
);

INSERT INTO teams ("name", "NOC_code")
SELECT DISTINCT
    "team", 
    "noc"
FROM base_de_table;


-- On vérifie : SELECT * FROM teams LIMIT 10;

CREATE TABLE games (
    "id" INTEGER,
    "year" INTEGER NOT NULL,
    "season" TEXT CHECK (season IN ('Summer', 'Winter')) NOT NULL,
    "city" TEXT NOT NULL,
    PRIMARY KEY ("id")
);

INSERT INTO games ("year", "season", "city")
SELECT DISTINCT "year", "season", "city"
FROM base_de_table
WHERE "year" IS NOT NULL AND "season" IS NOT NULL AND "city" IS NOT NULL;

-- Ici on en a uniquement 9 car on a du supprimer plus de 150 000 observations (taille trop lourde pour github)
-- mais sinon il y avait à peu près 70

-- ensuite on fait sport 

CREATE TABLE sport (
    "id" INTEGER,
    "sport_name" TEXT NOT NULL, 
    PRIMARY KEY("id")
);

INSERT INTO sport ("sport_name")
SELECT DISTINCT "sport"
FROM base_de_table
WHERE "sport" IS NOT NULL;

-- comme d'hab on vérifie 

SELECT * FROM sport LIMIT 10;

-- table events (rappel : chaque events dépend d'un sport, donc liaison entre les deux tables)
-- sport n'est cependant pas lié à participations
-- voir diagramme ER dans readme

CREATE TABLE events (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "event_name" TEXT NOT NULL,
    "sport_id" INTEGER NOT NULL,
    FOREIGN KEY ("sport_id") REFERENCES sport("id")
);


INSERT INTO events ("event_name", "sport_id")
SELECT DISTINCT b."event", s."id"
FROM base_de_table AS b
JOIN sport AS s ON b."sport" = s."sport_name"
WHERE b."event" IS NOT NULL;

-- attention ici faut faire une jointure des sports, i.e recup joindres là ou les sports sont les mêmes 
-- dans base_de_table et sport, afin de récuperer l'id du sport depuis la jointure


-- Enfin, il faut créer la table centrale du schéma : participations
-- celle-ci va nécessite bcp de jointures

CREATE TABLE participations (
    "id" INTEGER,
    "athlete_id" INTEGER NOT NULL,
    "team_id" INTEGER NOT NULL,
    "game_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "medal" TEXT CHECK (medal IN ('Gold', 'Silver', 'Bronze') OR medal IS NULL),
    "age" INTEGER,
    "height" INTEGER,
    "weight" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("athlete_id") REFERENCES athletes("id"),
    FOREIGN KEY("team_id") REFERENCES teams("id"),
    FOREIGN KEY("game_id") REFERENCES games("id"),
    FOREIGN KEY("event_id") REFERENCES events("id")
);


INSERT INTO participations ("athlete_id", "team_id", "game_id", "event_id", "medal", "age", "height", "weight")
SELECT 
    b."id" AS "athlete_id",
    t."id" AS "team_id",
    g."id" AS "game_id",
    e."id" AS "event_id",
    b."medal",
    b."age",
    b."height",
    b."weight"
FROM base_de_table AS b
JOIN teams AS t ON b."team" = t."name" AND b."noc" = t."NOC_code"
JOIN games AS g ON b."year" = g."year" AND b."season" = g."season" AND b."city" = g."city"
JOIN events AS e ON b."event" = e."event_name"
JOIN sport AS s ON b."sport" = s."sport_name" AND e."sport_id" = s."id";


-- ne pas toucher 

-- rappel pour moi : A faire 

-- supprimer la table base_de_table après avoir effectué quelques vérification si les jointures sont correctes

-- voir s'il est possible d'optimiser, et surtout s'il y a besoin d'optimiser