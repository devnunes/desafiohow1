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

SELECT * FROM "Results" r limit 100;

create table "Countries" (
	id serial PRIMARY KEY,
	name varchar(100) null
);

--drop table "Countries"

insert into "Countries" (name) select distinct ("country") from "Results";

--SELECT * FROM "Countries" c limit 100;

create table "Cities" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

--drop table "Cities"

insert into "Cities" (name) 
	select distinct  r.city 
	from "Results" r

-- SELECT * FROM "Cities"

create table "Tournaments" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

insert into "Tournaments" (name) select distinct ("tournament") from "Results";

-- SELECT * FROM "Tournaments" t limit 100;

create table "Teams" (
	name varchar(100) null,
	id serial PRIMARY KEY
);

-- import from tables/teams.csv

--SELECT * FROM "Teams" t limit 100;'

create table "Matches" (
	"date" date,
	"home_team_id" int4,
	"away_team_id" int4,
	"tournament_id" int4,
	"city_id" int4,
	"country_id" int4,
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

insert into "Matches" (date, "home_team_id", "away_team_id", "tournament_id", "city_id", "country_id", neutral) 
	select r."date", homet.id, awayt.id, tourn.id, city.id, country.id, r.neutral
	from "Results" r
	join "Teams" homet on r.home_team = homet."name"
	join "Teams" awayt on r.away_team = awayt."name"
	join "Tournaments" tourn ON r.tournament = tourn."name" 
	join "Cities" city ON r.city = city."name"
	join "Countries" country ON r.country = country."name"

-- SELECT * FROM "Matches";
-- truncate table "Matches";

create table "Goal" (
	
	id serial PRIMARY KEY,
	
)

--drop schema public cascade;
--create schema public;


