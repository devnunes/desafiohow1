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
teamsTable = pd.DataFrame({"name": teamsDF["Teams"].unique()}).sort_values(by=["name"])
teamsTable.to_csv("tables/teams.csv", index=False)


# %%
# Country
countriesDF = pd.DataFrame({"name": results["country"].unique()}).sort_values(
    by=["name"]
)
print(countriesDF.shape)
countriesDF.to_csv("tables/countries.csv", index=False)

# %%
# City
citiesDF = pd.DataFrame({"name": results["city"].unique()}).sort_values(by=["name"])
print(citiesDF.shape)
citiesDF.to_csv("tables/cities.csv", index=False)
