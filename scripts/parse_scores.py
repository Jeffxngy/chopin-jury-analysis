import re
from pathlib import Path

import numpy as np
import pandas as pd
import pdfplumber

# Juror names, in the column order of the PDF
JURORS = [
    "Garrick Ohlsson", "John Allison", "Yulianna Avdeeva", "Michel Beroff",
    "Sa Chen", "Dang Thai Son", "Akiko Ebi", "Nelson Goerner",
    "Krzysztof Jabłoński", "Kevin Kenner", "Momo Kodama", "Robert McDonald",
    "Piotr Paleczny", "Ewa Pobłocka", "K. Popowa-Zydroń", "John Rink",
    "Wojciech Świtała",
]
N_JURORS = len(JURORS)
STAGES = ["Stage 1", "Stage 2", "Stage 3", "Final"]


def parse_original(cells):
    """'14 17 19s' -> [14.0, 17.0, 19.0, NaN]   (regex also splits glued tokens)"""
    text = " ".join(c for c in cells if c)
    tokens = re.findall(r"\d+|s", text)
    return [np.nan if t == "s" else float(t) for t in tokens]


def parse_corrected(cells):
    """'15,31 17,00 ...' -> [15.31, 17.0, ...]"""
    text = " ".join(c for c in cells if c).replace(",", ".")
    return [float(t) for t in text.split()]


pdf_path = sorted(Path("data/raw").glob("*.pdf"))[0]
print("Reading:", pdf_path.name)

records = []
stage_index = -1  # becomes 0 at the first header

with pdfplumber.open(pdf_path) as pdf:
    for page in pdf.pages:
        # a page with the column header starts a new stage
        if "Nr Imię Nazwisko" in (page.extract_text() or ""):
            stage_index += 1
        stage = STAGES[stage_index]

        for table in page.extract_tables():
            for row, next_row in zip(table, table[1:]):
                if row[0] is None:
                    continue
                first_cell = row[0].replace("\n", " ")
                match = re.search(r"(\d+)\s*([^\d]+?)\s+punktacja", first_cell)
                if not match:
                    continue

                number = int(match.group(1))
                name = match.group(2).strip()
                original = parse_original(row[1:-1])
                corrected = parse_corrected(next_row[1:-1])
                official_avg = float(row[-1].split()[-1].replace(",", "."))

                if len(original) != N_JURORS or len(corrected) != N_JURORS:
                    print(f"WARNING [{stage}] {name}: "
                          f"{len(original)} original / {len(corrected)} corrected scores, skipped")
                    continue

                for j in range(N_JURORS):
                    records.append({
                        "stage": stage,
                        "number": number,
                        "name": name,
                        "juror": JURORS[j],
                        "original": original[j],
                        "corrected": np.nan if np.isnan(original[j]) else corrected[j],
                        "official_avg": official_avg,
                    })

df = pd.DataFrame(records)

# Check 1: contestants per stage (expected: 84, 40, 20, 11)
print("\nContestants per stage:")
print(df.groupby("stage")["name"].nunique())

# Check 2: our average vs. the official one, now per stage
check = df.groupby(["stage", "name"]).agg(
    our_avg=("corrected", "mean"),
    official_avg=("official_avg", "first"),
)
check["difference"] = (check["our_avg"] - check["official_avg"]).round(2)
mismatches = check[check["difference"].abs() > 0.05]
print(f"\nMismatches: {len(mismatches)} of {len(check)}")
print(mismatches)

df.to_csv("data/processed/scores.csv", index=False)
print("\nSaved to data/processed/scores.csv")