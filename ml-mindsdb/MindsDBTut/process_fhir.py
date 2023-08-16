import json
import pandas as pd


### PULL DATA FROM FHIR JSON RESOURCE


def importData():
    with open('venv/resources/64994bc6e30fbe00124341a7_request.json', 'r') as file:
        data = json.load(file)
    return data


def execute():
    data = importData()

    count = 0
    ind = 0
    for entry in data["entry"]:
        resourceType = entry["resource"]["resourceType"]
        if resourceType == "Patient":
            ind += 1
        elif resourceType == "Observation":
            pass
        elif resourceType == "DiagnosticReport":
            pass
        print(ind, resourceType)
        count += 1

    print(count)
