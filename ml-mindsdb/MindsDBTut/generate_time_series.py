import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt


def time_series():
    data = pd.read_csv("venv/resources/new_data.csv")

    time_series_counts = {}

    for ind, row in data.iterrows():
        date = datetime.strptime(row["HIV_CONF"], '%Y-%m-%d')
        if date >= datetime(1970, 1, 1):
            temp = date.replace(day=1)
            year_month = temp.strftime('%Y-%m-%d')
            time_series_counts[year_month] = time_series_counts.get(year_month, 0) + 1

    new_df = pd.DataFrame([[k, v] for k, v in time_series_counts.items()], columns=["year-month", "count"])
    new_df = new_df.sort_values(by="year-month", ascending=True)

    new_df = new_df.reset_index(drop=True)[1:]

    new_df.to_csv("venv/resources/time_series_data.csv")

    plt.bar(new_df["year-month"], new_df["count"])
    plt.show()
