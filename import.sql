CREATE TABLE base_de_table (
  -- pas de primary key car il y a déjà un id compté parfois plusieurs fois
  id INTEGER,
  "name" TEXT NOT NULL,
  sex TEXT,
  age INTEGER,
  height INTEGER,
  "weight" INTEGER,
  team TEXT,
  noc TEXT,
  games TEXT,
  "year" INTEGER,
  season TEXT,
  city TEXT,
  sport TEXT,
  "event" TEXT,
  medal TEXT
);


-- run cette commande dans le terminal pour importer les données

.import --csv --skip 1 ATHLETE.csv base_de_table

-- après avoir importé, il faut run ces commandes pour supprimer les NA versions caractères
-- et mettre des vrais NULL

UPDATE base_de_table SET age = NULL WHERE age = 'NA';
UPDATE base_de_table SET height = NULL WHERE height = 'NA';
UPDATE base_de_table SET weight = NULL WHERE weight = 'NA';
UPDATE base_de_table SET medal = NULL WHERE medal = 'NA';


-- ensuite on importe dans le terminal à l'aide de 
-- .import --csv -- skip 1 