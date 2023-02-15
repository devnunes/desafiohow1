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

create table "Shootouts" (
	"date" date,	
	"team_id" int4,
	"home_team" varchar(100) null,
	"away_team" varchar(100) null, 
	id serial PRIMARY key,
	CONSTRAINT fk_team_winner
		FOREIGN  KEY(team_id)
			REFERENCES "Teams"(id)
);

insert into "Shootouts" (date, team_id, home_team, away_team)
	select sc."date", t.id, sc.home_team, sc.away_team
	from "Teams" t 
	join "Shootouts_csv" sc on t."name" = sc.winner;

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
			REFERENCES "Scores"(id),
	CONSTRAINT fk_shootout_match
		FOREIGN  KEY(shootout_id)
			REFERENCES "Shootouts"(id)
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

with "cte_match_teams" as (
	SELECT
	m.id,
	m.date,
	t1."name" as "home_team",
	t2."name" as "away_team"
	FROM "Matchs" m
	INNER JOIN "Teams" t1 ON m.home_team_id = t1.id
	INNER JOIN "Teams" t2 ON m.away_team_id = t2.id
), "cte_shootouts" as(
	select
		shoot.id as "shoot_id",
		cte_mt.id as "match_id"
	from "Shootouts" shoot
	join "cte_match_teams" cte_mt on cte_mt.date = shoot.date and cte_mt.home_team = shoot.home_team and cte_mt.away_team = shoot.away_team
)
update "Matchs"
	set "shootout_id" = cte_s."shoot_id"
	from (select * from "cte_shootouts") as cte_s
	WHERE 
    	"Matchs".id = cte_s.match_id;

--	join "cte_match_teams" m on m.date = shoot.date and m.home_team = shoot.home_team and m.away_team = shoot.away_team
alter table "Shootouts"
	drop column "date";
alter table "Shootouts"
	drop column "home_team";
alter table "Shootouts"
	drop column "away_team";

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
drop table "Matchs"
-- Insert data from results 

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
SELECT count(*) FROM "Results";
SELECT count(*) FROM "Countries";
SELECT count(*) FROM "Cities"
SELECT count(*) FROM "Tournaments";
select count(*) FROM "Teams";
select count(*) from "Shootouts"
SELECT count(*) FROM "Scores";
SELECT count(*) FROM "Matchs";
SELECT count(*) FROM "Goals";

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
	order by m."date" 

	-- Select Results rebuilded
select
	m.date, homet.name, awayt.name, s.home_score, s.away_score, t."name", city.name, country."name", m.neutral 
from "Matchs" m
	join "Scores" s on s.id = m.score_id
	join "Teams" homet on homet.id = m.home_team_id 
	join "Teams" awayt on awayt.id = m.away_team_id
	join "Tournaments" t ON t.id = m.tournament_id
	join "Cities" city ON m.city_id = city.id 
	join "Countries" country ON m.country_id  = country.id;

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

 with "teste" as (
 select distinct t.id as "home", t2.id as "away"
 	from "Matchs" m
	inner join "Teams" t ON t.id = m.home_team_id 
	inner join "Teams" t2 ON t2.id = m.away_team_id
 ), "teste2" as (
 	select count(*) from "Matchs" m
 		where m.home_team_id = ()
 )
 select * from "teste"
 	group by home, away

with "teste" as (
	select 
		t.name as "home",
		t2.name as "away",
		count(*) as "count"
		from "Matchs" m
		inner join "Teams" t ON t.id = m.home_team_id 
		inner join "Teams" t2 ON t2.id = m.away_team_id
		group by home, away
		union all 
		select 
		t2.name as "home",
		t.name as "away",
		count(*) as "count"
		from "Matchs" m
		inner join "Teams" t ON t.id = m.home_team_id 
		inner join "Teams" t2 ON t2.id = m.away_team_id
		group by home, away
 ), "teste2" as(
	select  
	concat(
	"home",
	' X ',
	"away") as "chave",
	count
	from "teste" m
	)
	select chave, count 
	from "teste2"
	where chave = (select distinct chave from teste)
	and chave like 'En%'
	and chave like 'Es%'
	order by chave;

with "teste" as (
select t.home_team_id as "h", t.away_team_id as "a"
from "Matchs" t
join (
    select home_team_id, away_team_id, count(*) from (
      select home_team_id, away_team_id from "Matchs" where home_team_id <= away_team_id
      union all
      select away_team_id, home_team_id from "Matchs" where home_team_id > away_team_id) x
    group by home_team_id, away_team_id
    having count(*) > 1) y
  on (t.home_team_id = y.home_team_id and t.away_team_id = y.away_team_id)
    or (t.home_team_id = y.away_team_id and t.away_team_id = y.home_team_id)
 )
 	select distinct  * from "teste";

	
	
 
drop schema public cascade;
create schema public;