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
	"scorer" varchar(100) null,
	"minute" int4,
	"own_goal" BOOLEAN,
	"penalty" BOOLEAN,
)

create table "Shootouts" (
	"date" date,
	"home_team" varchar(100) null,
	"away_team" varchar(100) null,
	"winner" varchar(100) null
)

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

-- Import dataset/goalscores.csv into results table
SELECT * FROM "Goalscores";

-- Import dataset/shootouts.csv into results table
SELECT * FROM "Shootouts";

-- import from tables/teams.csv
SELECT * FROM "Teams";

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



-- Insert data from results 
insert into "Countries" (name) select distinct ("country") from "Results";

insert into "Cities" (name) 
	select distinct  r.city 
	from "Results" r;

insert into "Tournaments" (name) select distinct ("tournament") from "Results";

insert into "Matches" (date, "home_team_id", "away_team_id", "tournament_id", "city_id", "country_id", neutral) 
	select r."date", homet.id, awayt.id, tourn.id, city.id, country.id, r.neutral
	from "Results" r
	join "Teams" homet on r.home_team = homet."name"
	join "Teams" awayt on r.away_team = awayt."name"
	join "Tournaments" tourn ON r.tournament = tourn."name" 
	join "Cities" city ON r.city = city."name"
	join "Countries" country ON r.country = country."name";

	
-- Selects
SELECT count(*) FROM "Results";
SELECT * FROM "Countries";
SELECT count(*) FROM "Cities"
SELECT count(*) FROM "Tournaments";
select count(*) FROM "Teams";
SELECT count(*) FROM "Matches";
SELECT * FROM "Matches";


create table "Goal" (
	
	id serial PRIMARY KEY,
	
)

drop schema public cascade;
create schema public;
