import sqlite3, pandas as pd

df = pd.read_csv('input/legal_full_2026-01-20_23-28-59.csv')

ds = sqlite3.connect('output/legal_firms.db')

df.to_sql('firms', ds, if_exists='replace', index=False)