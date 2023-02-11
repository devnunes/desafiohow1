# %%
# Imports
import pandas as pd
import numpy as np

# %%
# Ingestão csv
shootouts = pd.read_csv("./dataset/shootouts.csv")
goalscorers = pd.read_csv("./dataset/goalscorers.csv")
results = pd.read_csv("./dataset/results.csv")

# %%
# All teams
homeShootoutsColumn = shootouts["home_team"].unique()
awayShootoutsColumn = shootouts["away_team"].unique()
homeGoalscorersColumn = goalscorers["home_team"].unique()
awayGoalscorersColumn = goalscorers["away_team"].unique()
homeResultsColumn = results["home_team"].unique()
awayResultsColumn = results["away_team"].unique()

teamsDF = pd.DataFrame(
    {
        "Teams": np.concatenate(
            (
                homeShootoutsColumn,
                awayShootoutsColumn,
                homeGoalscorersColumn,
                awayGoalscorersColumn,
                homeResultsColumn,
                awayResultsColumn,
            )
        )
    }
)
teamsTable = pd.DataFrame({"name": teamsDF["Teams"].unique()}).sort_values(by=["name"])
teamsTable.to_csv("./tables/teams.csv", index=False)

# %%
# Country
countriesDF = pd.DataFrame({"name": results["country"].unique()}).sort_values(
    by=["name"]
)
print(countriesDF.shape)
countriesDF.to_csv("./tables/countries.csv", index=False)

# %%
# City
citiesDF = pd.DataFrame({"name": results["city"].unique()}).sort_values(by=["name"])
print(citiesDF.shape)
citiesDF.to_csv("./tables/cities.csv", index=False)

# %%
# All teams goalscorers
teamsTable = pd.DataFrame({"name": goalscorers["team"].unique()}).sort_values(
    by=["name"]
)
teamsTable.to_csv("./tables/teams_goalscorers.csv", index=False)

# %%
# All scores
scoresColumns = (
    results.groupby(["home_score", "away_score"])
    .size()
    .reset_index()
    .rename(columns={0: "count"})
)
# homeScoreColumn = np.unique(results[["home_score", "away_score"]].values)
# awayScoreColumn = results["away_score"].unique()

print(scoresColumns)
# print(awayScoreColumn.shape)

scoresTable = pd.DataFrame(
    {
        "home_score": scoresColumns["home_score"],
        "away_score": scoresColumns["away_score"],
    }
)
scoresTable.to_csv("./tables/scores.csv", index=False)

# %%
