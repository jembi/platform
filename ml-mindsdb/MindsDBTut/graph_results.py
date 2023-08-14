import matplotlib.pyplot as plt
import pandas as pd


def graph():

    results = pd.read_csv("venv/resources/results.csv")
    print(results)

    plt.plot(results["real"], label="Real data")
    plt.plot(results["auto_arima"][640:], label="auto_arima")
    plt.plot(results["lightwood"], label="lightwood")
    plt.plot(results["statsforecast"], label="statsforecast")

    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Data')
    plt.legend()
    
    # years_locator = mdates.YearLocator()
    # years_formatter = mdates.DateFormatter('%Y')
    # plt.gca().xaxis.set_major_locator(years_locator)
    # plt.gca().xaxis.set_major_formatter(years_formatter)
    #
    # plt.xticks(rotation=45)
    #
    # plt.grid(axis='x')

    plt.show()
