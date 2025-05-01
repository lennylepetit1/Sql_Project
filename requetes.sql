/* Requete 1 - Requête Simple - Liste des athlètes avec leurs informations. */

SELECT * FROM athletes;

/* Run Time: real 1.497 user 0.029171 sys 0.089960 */

/* Requete 2 -  Requête Simple avec Filtre - Athlètes ayant gagné une médaille d'or. */

SELECT a.name, a.sex, p.medal
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
WHERE p.medal = 'Gold';

/* Run Time: real 0.042 user 0.012964 sys 0.008416 */

/* Requete 3 -  Requête avec Agrégation - Nombre de médailles par sport. */

SELECT s.sport_name, COUNT(p.medal) AS total_medals
FROM participations p
JOIN events e ON p.event_id = e.id
JOIN sport s ON e.sport_id = s.id
WHERE p.medal IS NOT NULL
GROUP BY s.sport_name
ORDER BY total_medals DESC;

/* Run Time: real 0.008 user 0.005565 sys 0.002091 */

/* Requete 4 -  Requête avec Jointure - Athlètes et leurs équipes. */

SELECT a.name, t.name AS team_name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN teams t ON p.team_id = t.id;

/* Run Time: real 2.647 user 0.093093 sys 0.193168 */

/* Requete 5 -  Requête avec Filtrage - Athlètes ayant participé à un événement spécifique (par exemple, "100m Sprint"). */

SELECT DISTINCT a.name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE e.event_name LIKE '%Badminton%';

/* Run Time: real 0.039 user 0.030167 sys 0.005496 */

/* Requete 6 -  Requête Avancée - Athlètes ayant participé à plusieurs Jeux Olympiques. */

SELECT a.name, COUNT(DISTINCT p.game_id) AS nb_games
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
GROUP BY a.id
HAVING nb_games > 1;

/* Run Time: real 0.330 user 0.083283 sys 0.040447 */

/* Requete 7 -  Requête avec Agrégation et Filtrage - Nombre de médailles d'or par équipe. */

SELECT t.name AS team_name, COUNT(*) AS gold_medals
FROM participations p
JOIN teams t ON p.team_id = t.id
WHERE p.medal = 'Gold'
GROUP BY t.name
ORDER BY gold_medals DESC;

/* Run Time: real 0.006 user 0.005552 sys 0.000191 */

/* Requete 8 -  Requête avec Sous-Requête - Athlètes ayant remporté une médaille d'or dans un événement spécifique */

SELECT DISTINCT a.name
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE p.medal = 'Gold'
  AND e.event_name LIKE '%Badminton%';

/* Run Time: real 0.010 user 0.006688 sys 0.002281 */

/* Requete 9 - Requête Complexe - Athlètes ayant participé à des événements d'hiver ou d'été et leurs médailles */

SELECT a.name, g.season, p.medal
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN games g ON p.game_id = g.id;

/* Run Time: real 2.490 user 0.109523 sys 0.183951 */

/* Requete 10 - Requête avec Filtrage Avancé - Athlètes ayant remporté plusieurs médailles d'or dans différents événements */

SELECT a.name, COUNT(DISTINCT e.id) AS nb_events
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE p.medal = 'Gold'
GROUP BY a.id
HAVING nb_events > 1;

/* Run Time: real 0.011 user 0.009559 sys 0.000364 */

/* Requete 11 - Les 3 athlètes les plus âgés ayant remporté une médaille d'or */

SELECT a.name, MAX(p.age) AS max_age
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
WHERE p.medal = 'Gold' AND p.age IS NOT NULL
GROUP BY a.id
ORDER BY max_age DESC
LIMIT 3;

/* Run Time: real 0.008 user 0.004906 sys 0.002810 */

/* Requete 12 - Hauteur moyenne des hommes ayant remporté une médaille au saut à la perche */

SELECT AVG(p.height) AS avg_height
FROM participations p
JOIN athletes a ON p.athlete_id = a.id
JOIN events e ON p.event_id = e.id
WHERE a.sex = 'M' AND p.medal IS NOT NULL AND e.event_name LIKE '%Pole Vault%';

/* Run Time: real 0.011 user 0.008487 sys 0.001502 */
