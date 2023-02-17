--Create Tables
create table "Results" (
	"date" date null,
	"home_team" varchar(100) null,
	"away_team" varchar(100) null,
	"home_score" int4 null,
	"away_score" int4 null,
	"tournament" varchar(300) null,
	"city" varchar(100) null,
	"country" varchar(100) null,
	"neutral" boolean null
);

create table "Goalscores" (
	"date" date null,
	"home_team" varchar(100) null,
	"away_team" varchar(100) null,
	"team" varchar(100) null,
	"scorer" varchar(300) null,
	"minute" int4,
	"own_goal" BOOLEAN,
	"penalty" BOOLEAN
);

create table "Shootouts_csv" (
	"date" date,
	"home_team" varchar(100) null,
	"away_team" varchar(100) null,
	"winner" varchar(100) null
);

create table "Countries" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

create table "Cities" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

create table "Tournaments" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

create table "Teams" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

create table "Scores" (
	"home_score" int4,
	"away_score" int4,
	id serial PRIMARY key
);

-- Import dataset/results.csv into results table
SELECT * FROM "Results";

insert into "Countries" (name)
	select distinct ("country")
	from "Results";

insert into "Cities" (name)
	select distinct  r.city 
	from "Results" r;

insert into "Tournaments" (name)
	select distinct ("tournament")
	from "Results";

-- import from tables/teams.csv
SELECT * FROM "Teams";

-- Import dataset/shootouts.csv into results table
SELECT * FROM "Shootouts_csv";

-- import from tables/scores.csv
SELECT * FROM "Scores";

-- Import tables/goalscorersCleaned.csv into results table
SELECT * FROM "Goalscores";

create table "Matchs" (
	"date" date,
	"home_team_id" int4,
	"away_team_id" int4,
	"tournament_id" int4,
	"city_id" int4,
	"country_id" int4,
	"score_id" int4,
	"shootout_id" int4 null,
	neutral boolean,
	id serial PRIMARY key,
	CONSTRAINT fk_home_team_match
		FOREIGN  KEY(home_team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_away_team_match
		FOREIGN  KEY(away_team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_tournament_match
		FOREIGN  KEY(tournament_id)
			REFERENCES "Tournaments"(id),
	CONSTRAINT fk_city_match
		FOREIGN  KEY(city_id)
			REFERENCES "Cities"(id),
	CONSTRAINT fk_country_match
		FOREIGN  KEY(country_id)
			REFERENCES "Countries"(id),
	CONSTRAINT fk_score_match
		FOREIGN  KEY(score_id)
			REFERENCES "Scores"(id)
);

insert into "Matchs"
	(
	date,
	"home_team_id",
	"away_team_id",
	"tournament_id",
	"city_id",
	"country_id",
	"score_id",
	neutral
	)
	select
		r."date",
		homet.id,
		awayt.id,
		tourn.id,
		city.id,
		country.id,
		sco.id,
		r.neutral
	from "Results" r
	join "Teams" homet on r.home_team = homet."name"
	join "Teams" awayt on r.away_team = awayt."name"
	join "Tournaments" tourn ON r.tournament = tourn."name" 
	join "Cities" city ON r.city = city."name"
	join "Countries" country ON r.country = country."name"
	join "Scores" sco ON r.home_score = sco.home_score and r.away_score = sco.away_score;
drop table "Shootouts";
drop table "Matchs" 
create table "Shootouts" (
	"team_id" int4,
	"match_id" int4,
	id serial PRIMARY key,
	CONSTRAINT fk_team_winner
		FOREIGN  KEY(team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_match_shootout
		FOREIGN  KEY(match_id)
			REFERENCES "Matchs"(id)
); 


WITH "cte_matchs" AS (
	SELECT
	m.id,
	m.date,
	t1."name" as "home_team",
	t2."name" as "away_team"
	FROM "Matchs" m
	INNER JOIN "Teams" t1 ON m.home_team_id = t1.id
	INNER JOIN "Teams" t2 ON m.away_team_id = t2.id
	)
insert into "Shootouts" (team_id, match_id)
	select t.id, m.id
	from "cte_matchs" m
	join "Shootouts_csv" sc on sc.date = m.date and sc.home_team = m.home_team and sc.away_team = m.away_team
	join "Teams" t ON t."name" = sc.winner; 


create table "Goals" (
	"player" varchar(100),
	"minute" int4,
	"own_goal" boolean,
	"penalty" boolean,
	"match_id" int4,
	"team_id" int4,
	id serial PRIMARY key,
	CONSTRAINT fk_match_goals
		FOREIGN  KEY(match_id)
			REFERENCES "Matchs"(id),
	CONSTRAINT fk_team_player
		FOREIGN  KEY(team_id)
			REFERENCES "Teams"(id)
); 

WITH "cte_matchs" AS (
	SELECT
	m.id,
	m.date,
	t1."name" as "home_team",
	t2."name" as "away_team"
	FROM "Matchs" m
	INNER JOIN "Teams" t1 ON m.home_team_id = t1.id
	INNER JOIN "Teams" t2 ON m.away_team_id = t2.id
	)
insert into "Goals" (player, minute, own_goal, penalty, match_id, team_id) 
	select g.scorer, g."minute", g.own_goal, g.penalty, m.id, t.id
	from "cte_matchs" m
	join "Goalscores" g on m."date" = g."date" and m.home_team = g.home_team and m.away_team = g.away_team
	join "Teams" t on t."name" = g.team;

-- Selects

SELECT count(*) FROM "Countries";
SELECT count(*) FROM "Cities";
SELECT count(*) FROM "Tournaments";
select count(*) FROM "Teams";
select count(*) from "Shootouts";
SELECT count(*) FROM "Scores";
SELECT count(*) FROM "Matchs";
SELECT count(*) FROM "Goals";

with "cte_countrie" as (SELECT count(*) as "countrie" FROM "Countries"),
"cte_cities" as (SELECT count(*) as "cities" FROM "Cities"),
"cte_tournaments" as (SELECT count(*) as "tournaments" FROM "Tournaments"),
"cte_teams" as (select count(*) as "teams" FROM "Teams"),
"cte_shootouts" as (select count(*) as "shootouts" FROM "Shootouts"),
"cte_scores" as (SELECT count(*) as "scores" FROM "Scores"),
"cte_matchs" as (SELECT count(*) as "matchs" FROM "Matchs"),
"cte_goals" as (SELECT count(*) as "goals" FROM "Goals")
SELECT * FROM
cte_countrie
UNION
SELECT * FROM
cte_cities
UNION
SELECT * FROM
cte_tournaments
UNION
SELECT * FROM
cte_teams
UNION
SELECT * FROM
cte_shootouts
UNION
SELECT * FROM
cte_scores
UNION
SELECT * FROM
cte_matchs
UNION
SELECT * FROM
cte_goals


SELECT * FROM "Scores";
select * from "Shootouts";

drop table "Results";
drop table "Shootouts_csv";
drop table "Goalscores";

select
	m."date",
	g.player,
	t3."name" as "player_team",
	g."minute",
	t."name" as "home_team",
	t2."name" as "away_team",
	tour.name as "campeonato",
	s.home_score,
	s.away_score
FROM "Goals" g
	inner join "Matchs" m ON m.id = g.match_id 
	inner join "Teams" t ON t.id = m.home_team_id 
	inner join "Teams" t2 ON t2.id = m.away_team_id
	inner join "Teams" t3 ON t3.id = g.team_id 
	inner join "Scores" s ON s.id = m.score_id
	inner join "Tournaments" tour ON tour.id = m.tournament_id
	order by m."date";


-- Dashboards do Grafana

-- Média de gols (Por campeonato)
WITH "cte_home_score" AS (
  select
    m.date,
    homet.name as team,
    s.home_score as score,
    t."name" as tournament
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" homet on homet.id = m.home_team_id
    join "Tournaments" t ON t.id = m.tournament_id
  where
    homet.name = 'Brazil'
),
"cte_away_score" as (
  select
    m.date,
    s.away_score as score,
    awayt.name as team,
    t."name" as tournament
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" awayt on awayt.id = m.away_team_id
    join "Tournaments" t ON t.id = m.tournament_id
  where
    awayt.name = 'Brazil'
),
"cte_brazil_matchs" as (
  select
    date,
    team,
    score,
    tournament
  from
    "cte_home_score"
  union
  select
    date,
    team,
    score,
    tournament
  from
    "cte_away_score"
)
select
  tournament as "Campeonato",
  avg(score) as "Média"
from
  "cte_brazil_matchs"
GROUP BY
  tournament;

-- Médias de gols em casa (Por Campeonato)
WITH "cte_home_score" AS (
  select
    m.date,
    homet.name as team,
    s.home_score as score,
    t."name" as tournament
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" homet on homet.id = m.home_team_id
    join "Tournaments" t ON t.id = m.tournament_id
  where
    homet.name = 'Brazil'
)
select
  tournament as "Campeonato",
  avg(score) as "Média"
from
  "cte_home_score"
GROUP BY
  tournament;

-- Médias de gols em casa (Total)
WITH "cte_home_score" AS (
  select
    m.date,
    homet.name as team,
    s.home_score as score
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" homet on homet.id = m.home_team_id
  where
    homet.name = 'Brazil'
)
select
  avg(score) as "Média",
  max(score) as "Total"
from
  "cte_home_score"

-- Médias de gols fora de casa (Total)
WITH "cte_away_score" as (
  select
    m.date,
    s.away_score as score,
    awayt.name as team
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" awayt on awayt.id = m.away_team_id
  where
    awayt.name = 'Brazil'
)
select
  avg(score) as "Média",
  max(score) as "Total"
from
  "cte_away_score"
 
-- Média de gols fora de casa (Por campeonato)
with "cte_away_score" as (
  select
    m.date,
    s.away_score as score,
    awayt.name as team,
    t."name" as tournament
  from
    "Matchs" m
    join "Scores" s on s.id = m.score_id
    join "Teams" awayt on awayt.id = m.away_team_id
    join "Tournaments" t ON t.id = m.tournament_id
  where
    awayt.name = 'Brazil'
)
select
  tournament as "Campeonato",
  avg(score) as "Média"
from
  "cte_away_score"
GROUP BY
  tournament;
    
-- Quantidade de jogos (Casa Vs. Visitante)
 select
  t.name as "Time da casa",
  t2."name" as "Time Visitante",
  count(*) as "Quantidade de jogos"
from
  "Matchs" m2
  inner join "Teams" t ON t.id = m2.home_team_id
  inner join "Teams" t2 ON t2.id = m2.away_team_id
group by
  "Time da casa",
  "Time Visitante";
 
 -- Quantidade de jogos vencidos por penalti
  select
  t3.name as "Vencedor dos penaltis",
  t."name" as "Campeonato",
  count(*) as "Partidas Vitóriosas"
from
  "Matchs" m
  inner join "Shootouts" s2 ON s2.match_id = m.id
  INNER JOIN "Teams" t3 ON s2.team_id = t3.id
  INNER JOIN "Tournaments" t ON m.tournament_id = t.id
  group by "Vencedor dos penaltis", "Campeonato"
  order by "Partidas Vitóriosas" desc;
 
-- Quantidade de jogos por países
 select
  country."name" as "País",
  count(m.id) as "Número de partidas"
from
  "Matchs" m
  join "Countries" country ON m.country_id = country.id
	group by country.name
  order by "Número de partidas";
 
-- Quantidade de jogos por países
 select
  country."name" as "País",
  count(m.id) as "Número de partidas"
from
  "Matchs" m
  join "Countries" country ON m.country_id = country.id
	group by country.name
  order by "Número de partidas";
  
-- Select Results rebuilded
select
  TO_CHAR(m.date:: DATE, 'dd/mm/yyyy') as "data",
  homet.name as "Time da Casa",
  awayt.name as "Time Visitante",
  s.home_score as "Placar Casa",
  s.away_score as "Placar Visitante",
  t."name" as "Campeonato",
  city.name as "Cidade",
  country."name" as "País",
  m.neutral
from
  "Matchs" m
  join "Scores" s on s.id = m.score_id
  join "Teams" homet on homet.id = m.home_team_id
  join "Teams" awayt on awayt.id = m.away_team_id
  join "Tournaments" t ON t.id = m.tournament_id
  join "Cities" city ON m.city_id = city.id
  join "Countries" country ON m.country_id = country.id;

 
drop schema public cascade;
create schema public;