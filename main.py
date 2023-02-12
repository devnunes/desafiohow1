# %% Imports
import pandas as pd
import numpy as np
import math

# %% Ingestão csv
shootouts = pd.read_csv("./dataset/shootouts.csv")
goalscorers = pd.read_csv("./dataset/goalscorers.csv")
results = pd.read_csv("./dataset/results.csv")

# %% All teams
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

# %% Country
countriesDF = pd.DataFrame({"name": results["country"].unique()}).sort_values(
    by=["name"]
)
print(countriesDF.shape)
countriesDF.to_csv("./tables/countries.csv", index=False)

# %% City
citiesDF = pd.DataFrame({"name": results["city"].unique()}).sort_values(by=["name"])
print(citiesDF.shape)
citiesDF.to_csv("./tables/cities.csv", index=False)

# %% All scores
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


# %% tratamento de minutos goalscores
# print(goalscorers["home_team"].dtype)
def averageMinutes(playerName, DF):
    return DF.loc[DF["scorer"] == playerName, "minute"].mean()


# %%
goalscorers2 = goalscorers
goalscorers3 = goalscorers
goalscorersNA = goalscorers
# retorna todos os gols sem o minute
goalscorersNA = goalscorersNA[
    pd.to_numeric(goalscorersNA.minute, errors="coerce").isnull()
]
# retorna todos os jogadores que não tem o minuto do gol
playersDF = pd.DataFrame({"player": goalscorersNA["scorer"].unique()})

# retorna os gols sem os jogos que não temos o minuto do jogo
goalscorers2 = goalscorers2[~goalscorers2["minute"].isnull()]

outLier = []
# verifica se o jogador tem outro jogo para podermos calcular a média dele
for row in playersDF.itertuples(index=False):
    value = averageMinutes(row.player, goalscorers2)
    if math.isnan(value):
        outLier.append(row.player)
    else:
        goalscorers3["minute"] = np.where(
            goalscorers3["scorer"] == row.player, value, goalscorers3["minute"]
        )

# Retira eles dos registros
goalscorers3 = goalscorers3[goalscorers3.scorer.isin(outLier) == False]
goalscorers3.to_csv("./tables/goalscorersCleaned.csv", index=False)

# %% calcular a média dos que sobraram
