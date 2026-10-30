import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

load_dotenv()

db_url = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT", "5432")),
    database=os.getenv("DB_NAME"),
)

engine = create_engine(db_url)

with engine.connect() as connection:
    df = pd.read_sql(
        text("SELECT * FROM v_housing_map LIMIT 10"),
        connection,
    )

print(df.head())
print(f"Rows loaded: {len(df)}")