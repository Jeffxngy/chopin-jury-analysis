import pandas as pd

df = pd.read_csv("data/processed/scores.csv")

totals = {}   # juror -> sum of their scores
counts = {}   # juror -> how many scores they gave
averages = {}

for juror, score in zip(df["juror"], df["original"]):
    if pd.isna(score):      # skip "s" (juror's own student)
        continue
    if juror not in totals:
        totals[juror] = 0
        counts[juror] = 0
    totals[juror] += score
    counts[juror] += 1

for juror in totals:
    averages[juror] = totals[juror]/counts[juror]

# TODO 3: for each juror in totals, compute totals / counts

for juror, avg in sorted(averages.items(), key=lambda item: item[1]):
    print(f"{juror:22s} {avg:.2f}")
print(df.groupby("juror")["original"].mean().sort_values().round(2))