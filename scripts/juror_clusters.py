import matplotlib.pyplot as plt
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

df = pd.read_csv("data/processed/scores.csv")
table = df.pivot_table(index=["stage", "name"], columns="juror", values="original")

table = table.fillna(table.mean())   # fill missing "s" with that juror's average
centered = table - table.mean()      # remove leniency, keep taste
X = centered.T                       # one row per juror
print(X.shape)  
                     # guess before running!
pca = PCA(n_components=2)        # "2 dimensions"
coords = pca.fit_transform(X)    # compute directions + map every juror

kmeans = KMeans(n_clusters=3, n_init=10, random_state=42) #n_init says how many times we do this and safes best result
labels = kmeans.fit_predict(X)   # run your loop, return a group per juror

plt.scatter(coords[:, 0], coords[:, 1], c=labels, cmap="viridis")
for name, (x, y) in zip(X.index, coords):
    plt.annotate(name, (x, y), fontsize=8)
plt.xlabel("PC 1")
plt.ylabel("PC 2")
plt.title("Jurors by scoring taste (2025)")
plt.tight_layout()
plt.show()