---
description: Allot CPU and RAM resources to services, per service, per server.
---

# Resource Allocations

## What it Means

### CPU

CPU allocations are specified as a portion of the total number of cores on the host system, i.e., a CPU limit of `2` in a `6-core` system is an effective limit of `33.33%` of the CPU, and a CPU limit of `6` in a `6-core` system is an effective limit of `100%` of the CPU.

### RAM

Memory allocations are specified as a number followed by their multiplier, i.e., 500M, 1G, 10G, etc.

## Defaults

As a default, each package contained in Platform is allocated a maximum of 3 GB of RAM, and 100% CPU usage.&#x20;

## Allocating Resources per Package

The resource allocation can be set on a per-package basis, as specified by the relevant environment variables found in the relevant [Packages section](packages/).

## Notes

* Be wary of allocating CPU limits to ELK Stack services. These seem to fail with CPU limits and their already implemented health checks.
* Take note to not allocate less memory to ELK Stack services than their JVM heap sizes.
* Exit code 137 indicates an out-of-memory failure. When running into this, it means that the service has been allocated too little memory.
