/* Requete 1 - Requête Simple - Liste des athlètes avec leurs informations. */

SELECT * FROM athletes;

/* Requete 2 -  Requête Simple avec Filtre - Athlètes ayant gagné une médaille d'or. */

SELECT a.name, a.sex, p.medal
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
WHERE p.medal = 'Gold';

/* Requete 3 -  Requête avec Agrégation - Nombre de médailles par sport. */

SELECT s.sport_name, COUNT(p.medal) AS total_medals
FROM participations p
JOIN events e ON p.event_id = e.id
JOIN sport s ON e.sport_id = s.id
WHERE p.medal IS NOT NULL
GROUP BY s.sport_name
ORDER BY total_medals DESC;

/* Requete 4 -  Requête avec Jointure - Athlètes et leurs équipes. */

SELECT a.name, t.name AS team_name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN teams t ON p.team_id = t.id;

/* Requete 5 -  Requête avec Filtrage - Athlètes ayant participé à un événement spécifique (par exemple, "100m Sprint"). */

SELECT DISTINCT a.name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE e.event_name LIKE '%Badminton%';

/* Requete 6 -  Requête Avancée - Athlètes ayant participé à plusieurs Jeux Olympiques. */

SELECT a.name, COUNT(DISTINCT p.game_id) AS nb_games
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
GROUP BY a.id
HAVING nb_games > 1;

/* Requete 7 -  Requête avec Agrégation et Filtrage - Nombre de médailles d'or par équipe. */

SELECT t.name AS team_name, COUNT(*) AS gold_medals
FROM participations p
JOIN teams t ON p.team_id = t.id
WHERE p.medal = 'Gold'
GROUP BY t.name
ORDER BY gold_medals DESC;

/* Requete 8 -  Requête avec Sous-Requête - Athlètes ayant remporté une médaille d'or dans un événement spécifique */

SELECT DISTINCT a.name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE p.medal = 'Gold'
  AND e.event_name LIKE '%Badminton%';

/* Requete 9 - Requête Complexe - Athlètes ayant participé à des événements d'hiver ou d'été et leurs médailles */

SELECT a.name, g.season, p.medal
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN games g ON p.game_id = g.id;

/* Requete 10 - Requête avec Filtrage Avancé - Athlètes ayant remporté plusieurs médailles d'or dans différents événements */

SELECT a.name, COUNT(DISTINCT e.id) AS nb_events
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE p.medal = 'Gold'
GROUP BY a.id
HAVING nb_events > 1;

/* Requete 11 - Les 3 athlètes les plus âgés ayant remporté une médaille d'or */

SELECT a.name, MAX(p.age) AS max_age
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
WHERE p.medal = 'Gold' AND p.age IS NOT NULL
GROUP BY a.id
ORDER BY max_age DESC
LIMIT 3;

/* Requete 12 - Hauteur moyenne des hommes ayant remporté une médaille au saut à la perche */

SELECT AVG(p.height) AS avg_height
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE a.sex = 'M' AND p.medal IS NOT NULL AND e.event_name LIKE '%Pole Vault%';
