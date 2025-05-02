# Projet de SQL 

## GROUPE : Meresse Thomas - Lepetit Lenny - Guerriero Amanda

## Introduction

Ce projet académique s'inscrit dans le cadre du cours d'infrastructure des données de notre master. Nous avons choisi comme sujet, de concevoir et implémenter une base de données relationnelle complète autour des Jeux Olympiques (source du jeu de données : Kaggle), en appliquant les principes fondamentaux de normalisation, d'optimisation et d'interrogation des données. La base de données permet de stocker et d'analyser les données concernant les athlètes, les équipes, les sports, les événements, les médailles et les participations aux différentes éditions des Jeux Olympiques depuis plusieurs années. Ce système offre la possibilité d'effectuer des recherches complexes et des analyses statistiques sur les performances olympiques à travers l'histoire.

Nous avons trouvé une base de données sur Kaggle qui reprend les participants aux JO depuis 1900, avec leur pays d'origine, leur sports, leur âge, taille, poids, si ils ont reçu une médaille, etc.
Notre objectif est d'effectuer des requêtes sur cette base de données que nous avons limié pour aller de 2000 à 2016.

## Déroulement 

Nous avons téléchargé le dataset suivant : **120 years of Olympic history: athletes and results**, sur kaggle. Il contient tous les jeux olympiques depuis 1896 à Athène, jusqu'à 2016 à Rio. 

Cette base de données au format csv contient 271116 lignes and 15 colonnes (variables). Chaque ligne correspond à un athlète individuel participant à une épreuve olympique individuelle (athlètes-épreuves). Toutefois, un athlète peut être présent plusieurs fois (participer à plusieurs jeux olympiques et/ou épreuves olympiques). Cela nécessitera donc de la prudence quant à la création des bases relationnelles, puisque l'id apparaît plusieurs fois. 

Les colonnes sont les suivantes :
- ID
- Nom
- Sexe
- Age
- Taille
- Poids
- Equipe (pays)
- NOC (National Olympic Committee 3-letter code) [ex : FRA -> France]
- Jeux (année et saison)
- Année
- Ville (où se déroulent les jeux)
- Le sport [ex : Tennis]
- L'évènement sportif [ex : Tennis homme double]
- Médaille (null si pas de médaille)


*NB : La table ATHLETE.csv contenant plus de 270 000 lignes était très volumineuse, pour pouvoir importer la base dans codespace, nous avons dû réduire à environ 100 000 observations pour statisfaire les contraintes de volume.*


**Voici donc ce que nous avons fait, dans l'ordre :** 
- Division de la base de données brute, en 6 tables ayant une relation entre elles
- Test de plusieurs requêtes sur la nouvelle base de données
- Ajout de déclencheurs, permettant d'ajouter des nouvelles données manuellement, même après avoir divisé en 6 tables

## Division de la base de données brute

### Les objectifs

Voici tout d'abord, les objectifs que nous nous étions fixé au départ : 
- Concevoir un schéma de base de données normalisé et efficace
- Implémenter les relations entre les différentes entités du monde olympique
- Développer des requêtes SQL de complexité variée pour interroger les données
- Si besoin, optimiser les performances des requêtes via l'indexation et l'analyse des plans d'exécution (ici on a pas eu besoin)
- Développer des mécanismes d'insertion de données préservant l'intégrité référentielle

### Structure de la base de données 

Le schéma relationnel comprend 6 tables principales :
1. `athletes` - Informations sur les athlètes olympiques
2. `teams` - Données sur les équipes nationales
3. `games` - Éditions des Jeux Olympiques (année, saison, ville)
4. `sport` - Disciplines sportives
5. `events` - Épreuves spécifiques au sein de chaque sport
6. `participations` - Table centrale reliant athlètes, équipes, jeux et événements

Les tables ont des relations entre elles, vous pourrez les visualiser grâce au diagramme ER que nous avons fait ci-dessous (avec drawsql) : 

<img width="997" alt="image" src="https://github.com/user-attachments/assets/f3fff919-e972-48a9-820c-796bd103cf4d" />

Le modèle est conçu selon une architecture en étoile, avec la table `participations` au centre reliant toutes les autres entités. Toutes les tables seront stockées dans olympics.db. Pour voir ce schéma relationnel ci-dessus, deux choix s'offrent à vous : 
- sqlite3 olympics.db, et .schema
- Aller directement dans le fichier creation_tables.sql, pour voir tout le code

## Test de plusieurs requêtes, sur la nouvelle base 

Une fois que nous avons créé notre base relationnelle, nous l'avons testé avec plusieurs requête, d'une difficulté croissante. Chacune des requêtes fonctionnait. Ces multiples requêtes ont également été bénéfique pour jauger si notre base de données avait besoin d'être optimisée ou non, en effet, nous avons mesuré tous les temps de chaque requête à l'aide de `.timer on`, vous pourrez d'ailleurs retrouver le temps de chaque requête dans requetes.sql. Les résultats ici nous donne des temps tout à fait correct, il n'y a donc pas eu besoin d'optimisation, c'était prévisible car il faudrait plusieurs millions de lignes pour commencer à avoir des résultats long. Néamoins, il était nécessaire de vérifier. Ci-dessous, vous trouverez le listing des 12 requêtes : 

1. Requête Simple - Liste des athlètes avec leurs informations.
2. Requête Simple avec Filtre - Athlètes ayant gagné une médaille d'or.
3. Requête avec Agrégation - Nombre de médailles par sport.
4. Requête avec Jointure - Athlètes et leurs équipes.
5. Requête avec Filtrage - Athlètes ayant participé à un événement spécifique (par exemple, "100m Sprint").
6. Requête Avancée - Athlètes ayant participé à plusieurs Jeux Olympiques.
7. Requête avec Agrégation et Filtrage - Nombre de médailles d'or par équipe.
8. Requête avec Sous-Requête - Athlètes ayant remporté une médaille d'or dans un événement spécifique.
9. Requête Complexe - Athlètes ayant participé à des événements d'hiver et ayant remporté une médaille d'or.
10. Requête avec Filtrage Avancé - Athlètes ayant remporté plusieurs médailles d'or dans différents événements
11. Requête moyenne - Les 3 athlètes les plus âgés ayant remporté une médaille d'or
12. Requête Avancée - Hauteur moyenne des hommes ayant remporté une médaille au saut à la perche

## Ajout de déclencheurs 

Pour finir, nous avons ajouté des déclencheurs. 

### Mécanisme d'insertion et déclencheurs

Pour faciliter l'ajout de nouvelles données tout en préservant l'intégrité référentielle entre les tables normalisées, nous avons implémenté un mécanisme de déclencheurs (triggers) SQLite. Ce système permet d'insérer des données simplement dans la table de base, puis de propager automatiquement ces informations dans l'ensemble du schéma normalisé. Autrement dit, nous avons fait le choix de garder la table de base, celle-ci ayant désormais pour unique but l'ajout de données, qui déclenche sur les 6 autres tables. 

### Fonctionnement du déclencheur principal

Le déclencheur `insertion_base_table` s'active après chaque insertion dans la table `base_de_table` et exécute les opérations suivantes :
1. Insertion de l'athlète dans la table `athletes` (si non existant, sinon ignore)
2. Insertion de l'équipe dans la table `teams` (si non existante, sinon ignore)
3. Insertion des jeux dans la table `games` (si non existants, sinon ignore)
4. Insertion du sport dans la table `sport` (si non existant, sinon ignore)
5. Insertion de l'événement dans la table `events` (si non existant, sinon ignore)
6. Création de l'enregistrement de participation dans la table `participations`

Ce mécanisme utilise les instructions `INSERT OR IGNORE` pour éviter les doublons dans les tables de référence et effectue les jointures nécessaires pour récupérer les identifiants appropriés. 

### Cette approche à plusieurs avantages 

- Possibilité d'ajouter des données via une seule instruction `INSERT`
- Maintien automatique des relations entre les tables
- Évite les doublons dans les tables de référence
- Centralisation de la logique d'insertion dans un seul endroit [i.e. ça évite d'avoir à ajouter dans 6 tables, de vérifier si l'id existait déjà, ...] 
