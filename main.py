# %%
# Imports
import pandas as pd
import numpy as np

# %%
# Ingestão csv
# shootouts = pd.read_csv("./dataset/shootouts.csv")
# goalscorers = pd.read_csv("./dataset/goalscorers.csv")
results = pd.read_csv("./dataset/results.csv")

# %%
# All teams
homeColumn = results["home_team"].unique()
awayColumn = results["away_team"].unique()
teamsDF = pd.DataFrame({"Teams": np.concatenate((homeColumn, awayColumn))})
teamsTable = pd.DataFrame({"Teams": teamsDF["Teams"].unique()}).sort_values(
    by=["Teams"]
)
teamsTable.to_csv("tables/teams.csv", index=False)


# %%
# Country
countriesDF = pd.DataFrame({"Countries": results["country"].unique()})
print(countriesDF)
countriesDF.to_csv("tables/countries.csv", index=False)
