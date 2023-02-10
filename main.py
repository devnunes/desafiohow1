# %%
# Imports
import pandas as pd
import numpy as np

# %%
# Ingestão csv
shootouts = pd.read_csv("shootouts.csv")
# goalscorers = pd.read_csv("goalscorers.csv")
# results = pd.read_csv("results.csv")

# %%
# Shoot Outs
homeColumn = shootouts["home_team"].unique()
awayColumn = shootouts["away_team"].unique()
teamsDF = pd.DataFrame({"Teams": np.concatenate((homeColumn, awayColumn))})
teamsTable = pd.DataFrame({"Teams": teamsDF["Teams"].unique()})
teamsTable.to_csv("teams.csv", index=False)


# %%
