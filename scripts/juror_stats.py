import pandas as pd

df = pd.read_csv("data/processed/scores.csv") #loads parsed table

stage1 = df[df["stage"] == "Stage 1"] #only keep rows 
leniency = stage1.groupby("juror")["original"].mean().sort_values() #average original score each juror gave
print(leniency.round(2))