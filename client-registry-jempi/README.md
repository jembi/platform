
# JeMPI Client Registry Component - docker-swarm

This component consists of two services:

* JeMPI Web UI - http://localhost:3033
* JeMPI API - http://localhost:50000/JeMPI

## Api endpoints

> This service uses the openhim mapping mediator to map fhir formated patients into the JeMPI format

### Registering a patient

via the api (in JeMPI format)

```sh
POST - http://localhost:50000/JeMPI/cr-register

{
    "candidateThreshold": 0.9,
    "sourceId": {
        "facility": "fac1",
        "patient": "pat1"
    },
    "uniqueInteractionData": {
        "auxDateCreated": "2016-10-30T14:22:25.285",
        "auxId" : "1234",
        "auxClinicalData" : "SOME DATA"
    },
    "demographicData": {
        "givenName": "XXX",
        "familyName": "YYY",
        "gender": "female",
        "dob": "20000101",
        "phoneNumberMobile": "123456789",
        "city": "Cape Town",
        "nationalId": "1234567890"
    }
}
```

via the [mapping mediator](https://github.com/jembi/openhim-mediator-mapping) (in fhir format)

```sh

POST http://localhost:3003/fhir/Patient

{
    "resourceType": "Patient",
    "gender": "male",
    "birthDate": "1968-04-15",
    "name": [
        {
            "family": "cread",
            "given": [
                "Jacess"
            ]
        }
    ],
    "address": [
        {
            "city": "Indianapolis"
        }
    ],
    "identifier": [
        {
            "system": "https://instantopenhie.org/client1",
            "value": "6b4573e7-f9dc-49ea-9ebb-daaa6b74a534"
        },
        {
            "value": "60934be6-ce88-48af-958e-02d88f77eec9",
            "system": "NationalID"
        }
    ],
    "telecom": [
        {
            "value": "899-882-4991",
            "system": "phone"
        }
    ]
}
```
> The identifier with the system 'NationalID' maps to the 'nationalId' property in JeMPI

## Querying a patient by id

via the api (returns patient in JeMPI formated)

```sh
GET - http://localhost:50000/JeMPI/expanded-golden-record/<PATIENT_GOLDEN_ID>
```

via the [mapping mediator](https://github.com/jembi/openhim-mediator-mapping) (returns patient in fhir format)

```sh
GET - http://localhost:3003/fhir/Patient/<PATIENT_GOLDEN_ID>
```

## Updating a patient

via the api (in JeMPI format)

```sh
PATCH - http://localhost:50000/JeMPI/cr-update-fields

{
  "goldenId": "0x5",
  "fields": [
    {
      "name": "givenName",
      "value": "xxx"
    },
    {
      "name": "familyName",
      "value": "yyy"
    }
  ]
}
```

via the [mapping mediator](https://github.com/jembi/openhim-mediator-mapping) (in fhir format)

```sh
PUT - http://localhost:3003/fhir/update/Patient/<PATIENT_GOLDEN_RECORD>

{
    "resourceType": "Patient",
    "gender": "male",
    "birthDate": "1968-04-15",
    "name": [
        {
            "family": "cread",
            "given": [
                "Jacess"
            ]
        }
    ],
    "address": [
        {
            "city": "Indianapolis"
        }
    ],
    "identifier": [
        {
            "system": "https://instantopenhie.org/client1",
            "value": "6b4573e7-f9dc-49ea-9ebb-daaa6b74a534"
        },
        {
            "value": "60934be6-ce88-48af-958e-02d88f77eec9",
            "system": "NationalID"
        }
    ],
    "telecom": [
        {
            "value": "899-882-4991",
            "system": "phone"
        }
    ]
}
```

## Query all patients deterministic

via the api (returns in JeMPI format)

```sh
POST http://localhost:50000/JeMPI/cr-find

{
  "operand": {
    "fn": "eq",
    "name": "givenName",
    "value": "xxx"
  },
  "operands": [
    {
      "operator": "and",
      "operand": {
        "fn": "eq",
        "name": "familyName",
        "value": "yyy"
      }
    }
  ]
}
```

via the [mapping mediator](https://github.com/jembi/openhim-mediator-mapping) (in fhir format)

```sh
POST http://localhost:3003/fhir/Patients

{
    "resourceType": "Parameters",
    "parameters": [
        {
            "name": "and",                              // matches to the operator (options are "and" and "or")
            "valueCode": "familyName",                  // matches to the field name (options are "givenName", "familyName", "dob", "nationalId", "gender", "city" and "phoneNumberMobile")
            "valueString": "creexxxeead"                // matches to value of the field
        },
        {
            "name": "and",
            "valueCode": "city",
            "valueString": "Indianapeeolis"
        }
    ]
}
```
