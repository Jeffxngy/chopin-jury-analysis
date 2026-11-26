import pandas as pd

df = pd.read_csv("data/processed/scores.csv") #loads parsed table

for stage in df["stage"].unique():
    stage_df = df[df["stage"] == stage] #only keep rows 
    leniency = stage_df.groupby("juror")["original"].mean().sort_values() #average original score each juror gave
    print(f"\n=== {stage} ===")
    print(leniency.round(2))