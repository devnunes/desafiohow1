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
-- drop table "Goalscores" 

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

-- Import dataset/results.csv into results table
SELECT * FROM "Results";

-- Import dataset/shootouts.csv into results table
SELECT * FROM "Shootouts_csv";

-- Import tables/goalscorersCleaned.csv into results table
SELECT * FROM "Goalscores";

-- import from tables/teams.csv
SELECT * FROM "Teams";

create table "Matchs" (
	"date" date,
	"home_team_id" int4,
	"away_team_id" int4,
	"tournament_id" int4,
	"city_id" int4,
	"country_id" int4,
	"home_score" int4,
	"away_score" int4,
	neutral boolean,
	id serial PRIMARY key,
	CONSTRAINT fk_home_team
		FOREIGN  KEY(home_team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_away_team
		FOREIGN  KEY(away_team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_tournament
		FOREIGN  KEY(tournament_id)
			REFERENCES "Tournaments"(id),
	CONSTRAINT fk_city
		FOREIGN  KEY(city_id)
			REFERENCES "Cities"(id),
	CONSTRAINT fk_country_match
		FOREIGN  KEY(country_id)
			REFERENCES "Countries"(id)
);
--drop table "Matchs"

create table "Scores" (
	"home_score" int4,
	"away_score" int4,
	id serial PRIMARY KEY
)

-- import from tables/scores.csv
SELECT * FROM "Scores";

create table "Matchs_scores" (
	"match_id" int4 null,	
	"score_id" int4 null,
	id serial PRIMARY KEY,
	CONSTRAINT fk_matchs_scores_goals
		FOREIGN  KEY(match_id)
			REFERENCES "Matchs"(id),
	CONSTRAINT fk_scores_matchs_goals
		FOREIGN  KEY(score_id)
			REFERENCES "Scores"(id)
)

create table "Goals" (
	"player" varchar(100),
	"minute" varchar(4),
	"own_goal" boolean,
	"penalty" boolean,
	"team_id" int4,
	"match_score_id" int4,
	id serial PRIMARY key,
	CONSTRAINT fk_team_goal
		FOREIGN  KEY(team_id)
			REFERENCES "Teams"(id),
	CONSTRAINT fk_match_score
		FOREIGN  KEY(match_score_id)
			REFERENCES "Matchs_scores"(id)
);

-- drop table "Goals"

create table "Shootouts" (
	"match_score_id" int4,
	"team_id" int4,
	id serial PRIMARY key,
	CONSTRAINT fk_match_shootout
		FOREIGN  KEY(match_score_id)
			REFERENCES "Matchs_scores"(id),
	CONSTRAINT fk_team_winner
		FOREIGN  KEY(team_id)
			REFERENCES "Teams"(id)
)

-- Insert data from results 
insert into "Countries" (name) select distinct ("country") from "Results";

insert into "Cities" (name)
	select distinct  r.city 
	from "Results" r;

insert into "Tournaments" (name) select distinct ("tournament") from "Results";

insert into "Matchs" (date, "home_team_id", "away_team_id", "tournament_id", "city_id", "country_id", "home_score", "away_score", neutral) 
	select r."date", homet.id, awayt.id, tourn.id, city.id, country.id, r.home_score, r.away_score, r.neutral
	from "Results" r
	join "Teams" homet on r.home_team = homet."name"
	join "Teams" awayt on r.away_team = awayt."name"
	join "Tournaments" tourn ON r.tournament = tourn."name" 
	join "Cities" city ON r.city = city."name"
	join "Countries" country ON r.country = country."name";

insert into "Matchs_scores" ("match_id","score_id") 
	select m.id, s.id
	from "Matchs" m
	join "Scores" s on s.home_score = m.home_score and s.away_score = m.away_score;

alter table "Matchs"
	drop column home_score;

alter table "Matchs"
	drop column away_score;


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
insert into "Goals" (player, minute, own_goal, penalty, team_id, match_score_id) 
	select g.scorer, g."minute", g.own_goal, g.penalty, t.id, ms.id 
	from "cte_matchs" m
	join "Goalscores" g on m."date" = g."date" and m.home_team = g.home_team and m.away_team = g.away_team
	join "Teams" t on t."name" = g.team
	join "Matchs_scores" ms on ms."match_id" = m.id;

WITH "cte_matchs_shootouts" AS (
	select
	m.id,
	m.date,
	t1."name" as "home_team",
	t2."name" as "away_team"
	FROM "Matchs" m
	INNER JOIN "Teams" t1 ON m.home_team_id = t1.id
	INNER JOIN "Teams" t2 ON m.away_team_id = t2.id
	)
insert into "Shootouts" (team_id,match_score_id) 
	select t.id, ms.id
	from "cte_matchs_shootouts" s
	join "Shootouts_csv" sc on sc."date" = s."date" and sc.home_team = s.home_team and sc.away_team = s.away_team
	join "Teams" t on t."name" = sc.winner
	join "Matchs_scores" ms on ms."match_id" = s.id;

select * from "Shootouts"


-- Select Results rebuilded
select
	m.date, homet.name, awayt.name, s.home_score, s.away_score, t."name", city.name, country."name", m.neutral 
from "Matchs" m
	join "Matchs_scores" ms on ms.match_id = m.id
	join "Scores" s on s.id = ms.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id;

select
	m.date, homet.name, awayt.name, s.home_score, s.away_score, t."name", city.name, country."name", m.neutral 
from "Matchs" m
	join "Matchs_scores" ms on ms.match_id = m.id
	join "Scores" s on s.id = ms.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id;


-- Selects
SELECT count(*) FROM "Results";
SELECT count(*) FROM "Countries";
SELECT count(*) FROM "Cities"
SELECT count(*) FROM "Tournaments";
select count(*) FROM "Teams";
SELECT count(*) FROM "Matchs";
SELECT count(*) FROM "Goals";
select count(*) from "Shootouts"
SELECT count(*) FROM "Matchs";
SELECT count(*) FROM "Matchs_scores";
SELECT count(*) FROM "Scores";
SELECT * FROM "Scores";
SELECT * FROM "Matchs_scores" ms;
SELECT * FROM "Matchs_scores";
select * from "Shootouts"
SELECT date, id FROM "Matchs";
select
	count(g.id),
	g.player,
	team.name,
	tour.name
	FROM "Goals" g
	inner join "Matchs_scores" ms ON ms.id = g.match_score_id 
	inner join "Matchs" m on m.id = ms.match_id
	inner join "Tournaments" tour on tour.id = m.tournament_id
	inner join "Teams" team ON team.id = g.team_id 
	where g.team_id = 39
	group by g.player, team."name", tour.name
	


WITH "cte_matchs_away" AS (
select
  m.date,
  homet.name as home_team,
  awayt.name as away_team,
  s.home_score,
  s.away_score,
  t."name" as tournament,
  city.name as city,
  country."name" as country,
  m.neutral 
from "Matchs" m
	join "Matchs_scores" ms on ms.match_id = m.id
	join "Scores" s on s.id = ms.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id
	order by m.date
	)
select
	date,
	home_team,
	home_score,
	away_score,
	away_team,
	tournament,
	country
	from
	"cte_matchs_away" cte
	where cte.home_team = 'Wales';

	
WITH "cte_home_score" AS (
select
  m.date,
  homet.name as team,  
  s.home_score as score,
  t."name" as tournament
from "Matchs" m
	join "Matchs_scores" ms on ms.match_id = m.id
	join "Scores" s on s.id = ms.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id
	where homet.name = 'Brazil' 
), "cte_away_score" as (
select
  m.date,
  s.away_score as score,
  awayt.name as team,
  t."name" as tournament
from "Matchs" m
	join "Matchs_scores" ms on ms.match_id = m.id
	join "Scores" s on s.id = ms.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id
	where awayt.name = 'Brazil'
	), "cte_brazil_matchs" as (
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
	team,
	tournament,
	avg(score)
	from "cte_brazil_matchs"
	GROUP BY team, tournament;
	
drop schema public cascade;
create schema public;