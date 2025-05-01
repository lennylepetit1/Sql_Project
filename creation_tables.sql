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

-- voir s'il est possible d'optimiser, et surtout s'il y a besoin d'optimiser notamment par rapport aux 12 requêtes

-- UPDATE : 01/05

-- les 12 requêtes ont été créées et on observe des temps très bon pour la plupart des requêtes; il y a uniquement 
-- 2 requêtes sur lesquelles les temps sont assez "gros" (voir ci-dessous), mais c'est normal car on sélectionne l'entièreté 
-- de la base, et parfois même avec un jointure. La création d'un index n'est pas nécessaire puisque c'est plus utile dans le cas
-- où l'on ferait des recherches et extrarait des échantillons des bases, et que là ça prendrait du temps.
-- Mais ici, quand on le fait les temps sont courts (voir requetes.sql).

--------------------------------------------------------------------------
---------------- Les requêtes un peu longues -----------------------------

/* Requete 1 - Requête Simple - Liste des athlètes avec leurs informations. */

SELECT * FROM athletes;

/* Run Time: real 1.497 user 0.029171 sys 0.089960 */

/* Requete 4 -  Requête avec Jointure - Athlètes et leurs équipes. */

SELECT a.name, t.name AS team_name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN teams t ON p.team_id = t.id;

/* Run Time: real 2.647 user 0.093093 sys 0.193168 */

--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- Maintenant quid de si on veut ajouter des données ? 

-- étant donné, que l'on a découpé en 6 tables, ça devient plus complexe. 

-- Mais ici, on a gardé la table de base (l'équivalent du csv), alors on peut l'utiliser non
-- pas pour faire des requêtes (puisqu'on utilise nos 6 tables pour ça) mais pour faire des ajouts
-- et avec des triggers, cela ajouter automatiquement les données aux 6 tables. 

CREATE TRIGGER insertion_base_table
AFTER INSERT ON base_de_table
FOR EACH ROW
BEGIN
    -- Insérer ou ignorer l'athlète (s'il existe déjà)
    INSERT OR IGNORE INTO athletes (id, name, sex)
    VALUES (NEW.id, NEW.name, NEW.sex);
    
    -- Insérer ou ignorer l'équipe
    INSERT OR IGNORE INTO teams (name, NOC_code)
    VALUES (NEW.team, NEW.noc);
    
    -- Insérer ou ignorer les jeux
    INSERT OR IGNORE INTO games (year, season, city)
    VALUES (NEW.year, NEW.season, NEW.city);
    
    -- Insérer ou ignorer le sport
    INSERT OR IGNORE INTO sport (sport_name)
    VALUES (NEW.sport);
    
    -- Insérer ou ignorer l'événement (nécessite de récupérer l'ID du sport)
    INSERT OR IGNORE INTO events (event_name, sport_id)
    VALUES (
        NEW.event,
        (SELECT id FROM sport WHERE sport_name = NEW.sport)
    );
    
    -- Enfin, insérer la participation
    INSERT INTO participations (
        athlete_id, team_id, game_id, event_id, medal, age, height, weight
    )
    VALUES (
        NEW.id,
        (SELECT id FROM teams WHERE name = NEW.team AND NOC_code = NEW.noc),
        (SELECT id FROM games WHERE year = NEW.year AND season = NEW.season AND city = NEW.city),
        (SELECT id FROM events WHERE event_name = NEW.event AND 
         sport_id = (SELECT id FROM sport WHERE sport_name = NEW.sport)),
        NEW.medal,
        NEW.age,
        NEW.height,
        NEW.weight
    );
END;


-- Si par exemple on ajoute l'observation suivante : 

INSERT INTO base_de_table (
    id, name, sex, age, height, weight, team, noc, 
    games, year, season, city, sport, event, medal
)
VALUES (
    135572, 'Thomas Meresse', 'M', 25, 180, 63, 'France', 'FRA',
    '2024 Summer', 2024, 'Summer', 'Paris', 'Tennis',
    'Tennis Mixed Doubles', 'Gold'
);

-- Et maintenant, si on run un code pour vérifier

SELECT name FROM athletes WHERE id = 135572;

-- On obtient bien Thomas Meresse

-- Ou encore, 

SELECT * FROM participations WHERE athlete_id = 135572;