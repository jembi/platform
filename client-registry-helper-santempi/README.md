
# SanteMPI Client Registry Helper Component - docker-swarm

This component consists of two services:

* MPI Checker mediator
* MPI Updater mediator

The two services above handle the creation of Patient resources in the Client Registry (SanteMPI) and the fhir datastore (Hapi-Fhir), from FHIR bundle inputs. Once a patient has been created or verified in SanteMPI, the patient and resources pertinent to it are stored in Hapi-fhir and then the updated bundle is sent to a kafka queue, `2xx`, where other services can consume it.
