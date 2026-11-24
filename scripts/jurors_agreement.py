import pandas as pd
import matplotlib.pyplot as plt



df = pd.read_csv("data/processed/scores.csv")

table = df.pivot_table(index=["stage", "name"], columns="juror", values="original")
print(table.shape)
print(table.head())
print(table.corr().round(2)) #how similar two jurors scores are from 0 to 1

#heat map
corr = table.corr()
plt.imshow(corr, cmap="viridis")
plt.colorbar()
plt.xticks(range(len(corr)), corr.columns, rotation=90)
plt.yticks(range(len(corr)), corr.columns)
plt.tight_layout()
plt.show()

#or let pandas find the pairs 
pairs = corr.stack()
pairs = pairs[pairs < 1]
print(pairs.sort_values().round(2))