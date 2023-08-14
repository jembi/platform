import math

import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import binom, uniform, expon
from random import randint


### IMPORT DATA FROM SYNTHEA AND ADD HIV CONFIRMATION DATA AND VIRAL LOAD
## ADDITIONS ARE SEMI DEPENDENT
# EXPORT TO new_data.csv


def generate():
    data = pd.read_csv("venv/resources/patients.csv")
    data["BIRTHDATE"] = pd.to_datetime(data["BIRTHDATE"], format="%Y/%m/%d")
    data["DEATHDATE"] = pd.to_datetime(data["DEATHDATE"], format="%Y/%m/%d")

    now = pd.Timestamp.now()
    ages = []
    hiv_confirmation = []

    for ind, row in data.iterrows():
        # generate random number of days between birth and now/death as date of HIV confirmation
        # add their age in years
        if pd.isnull(row["DEATHDATE"]):
            hiv_confirmation.append(row["BIRTHDATE"] +
                                    pd.DateOffset(randint(0, (pd.Timestamp.now() - row["BIRTHDATE"]).days)))
            ages.append((pd.Timestamp.now() - row["BIRTHDATE"]).days // 365)
        else:
            hiv_confirmation.append(row["BIRTHDATE"] +
                                    pd.DateOffset(randint(0, (row["DEATHDATE"] - row["BIRTHDATE"]).days)))
            ages.append((row["DEATHDATE"] - row["BIRTHDATE"]).days // 365)

    data["AGE"] = ages
    data["HIV_CONF"] = hiv_confirmation

    viral_load = []
    for ind, row in data.iterrows():
        # people having HIV for more than 2 years and less than 7 will have non-supressed HIV
        if 730 < (pd.Timestamp.now() - row["HIV_CONF"]).days < 2555:
            viral_load.append(round(expon.rvs(scale=8000)))
        # "new" HIV, or living with it for a long time have a higher chance of being virally supressed (<200)
        else:
            viral_load.append(round(expon.rvs(scale=200)))
    data["VIRAL_LOAD"] = viral_load

    data = data.reindex(columns=['Id', 'BIRTHDATE', 'DEATHDATE', 'AGE', 'SSN', 'FIRST', 'LAST', 'MAIDEN',
                                 'MARITAL', 'RACE', 'GENDER', 'COUNTY', 'ZIP', 'LAT', 'LON', 'HIV_CONF', 'VIRAL_LOAD'])
    data['YEARS_HIV_POS'] = categorise_conf_date(data['HIV_CONF'])

    data.to_csv("venv/resources/new_data.csv")
    # graph(data)
    return data


def graph(data=None):
    if data is None:
        data = generate()
    data = data.sort_values('YEARS_HIV_POS', ascending=True)
    # plt.scatter(y=data["LAT"], x=data["LON"], s=10, alpha=0.6)
    # plt.scatter(y=data["LAT"], x=data["LON"], c=categorise_vl(data['VIRAL_LOAD']), cmap='viridis', s=10, alpha=0.6)
    plt.scatter(y=data["LAT"], x=data["LON"], c=data['YEARS_HIV_POS'], cmap='viridis', s=10, alpha=0.6)
    raar = plt.colorbar()
    raar.set_label("Years")
    plt.title("HIV Patients location and years since HIV Positive date")
    plt.show()


def categorise_vl(data):
    new_col = []
    for ind, row in data.to_frame().iterrows():
        if row['VIRAL_LOAD'] < 200:
            new_col.append(0)
        elif row['VIRAL_LOAD'] < 5000:
            new_col.append(1)
        else:
            new_col.append(2)
    return pd.DataFrame(new_col)


def categorise_conf_date(data):
    new_col = []
    now = pd.Timestamp.now()
    length = (now - data) / pd.Timedelta(days=365.25)
    print(length)
    return length
