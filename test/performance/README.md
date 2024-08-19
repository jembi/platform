# Performance testing the IPS implementation

## Setup details

The performance runner utilizes K6 along with custom extensions for generating fake data.

To include additional extensions, refer to the following resources to build your desired binary:

- [Build a K6 Binary using Docker](https://k6.io/docs/extensions/guides/build-a-k6-binary-using-docker/)
- [K6 Extensions Documentation](https://k6.io/docs/extensions/)

Faker Extension:

- [GitHub Repository](https://github.com/szkiba/xk6-faker)
- [Documentation](https://ivan.szkiba.hu/xk6-faker/index.html)

## Building a k6 binary

Example command to build a binary with the Faker extension:

```
docker run --rm -u "$(id -u):$(id -g)" -v "${PWD}:/xk6" grafana/xk6 build --with github.com/szkiba/xk6-faker --with github.com/grafana/xk6-output-prometheus-remote@latest
```

## Run a specific performance test

Different types of performance testing can be implemented to verify various aspects of the system. Refer to the [Testing Guides](https://grafana.com/docs/k6/latest/testing-guides/test-types/) for an example guide.

#### Volume test

Ensure that all systems are connected and responding as intended.

```
./k6 run scripts/volume.js
```

#### Load test

Run the system under load by gradually increasing the number of Virtual Users (VUs) and maintaining this load for a specified duration before ramping down.

```
./k6 run scripts/load.js
```

#### Stress test

Apply a high load to the system by rapidly increasing the number of VUs and pushing the system to its limits.

```
./k6 run scripts/stress.js
```

#### Soak test

Run the system under a sustained load for an extended period to identify any potential performance degradation or resource leaks.

```
./k6 run scripts/soak.js
```

## Visualizing Results Output

The example k6 binary comes with a prometheus remote write extension which allows you to specify the prometheus endpoint where the load testing results will be pushed to.

To achieve this ensure the following variable is set correctly and the output flag enabled

```
K6_PROMETHEUS_RW_SERVER_URL=http://localhost:9090/api/v1/write \

./k6 run -o experimental-prometheus-rw scripts/volume.js
```

For more environment variables follow this link [here](https://k6.io/docs/results-output/real-time/prometheus-remote-write/#time-series-visualization)
