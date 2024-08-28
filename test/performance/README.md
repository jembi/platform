# Performance testing

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

#### Smoke Test

This test helps to verify that the system works well under minimal load and to gather baseline performance values. It is adviced to run this test before any other to ensure that essential services are booted and ready to handle requests.

```
./k6 run scripts/smoke.js
```

#### Volume test

Assess how the system performs under a typical load for your system or application.

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

To achieve this, ensure the following variable is set correctly and the output flag enabled

```
K6_PROMETHEUS_RW_SERVER_URL=http://localhost:9090/api/v1/write \

./k6 run -o experimental-prometheus-rw scripts/volume.js
```

For more environment variables, follow this link [here](https://k6.io/docs/results-output/real-time/prometheus-remote-write/#time-series-visualization)

## Sample Load test result

The test results were obtained from running on Ubuntu 22.04 OS, 64GB RAM and 12 Cores.
✓ status code is 200
| Metric | Value |
|--------------------------------|-------------|
| checks | 100.00% ✓ 188 ✗ 0 |
| data_received | 2.3 MB 39 kB/s |
| data_sent | 3.9 MB 65 kB/s |
| dropped_iterations | 1613 26.656141/s |
| http_req_blocked | avg=8.32µs min=3.54µs med=5.21µs max=259.88µs p(90)=6.87µs p(95)=8.18µs |
| http_req_connecting | avg=1.61µs min=0s med=0s max=153.25µs p(90)=0s p(95)=0s |
| http_req_duration | avg=619.01ms min=421.78ms med=621.54ms max=812.9ms p(90)=692.07ms p(95)=711.18ms |
| http_req_failed | 0.00% ✓ 0 ✗ 188 |
| http_req_receiving | avg=115.87µs min=60.86µs med=110.01µs max=508.35µs p(90)=152.09µs p(95)=158.61µs |
| http_req_sending | avg=125.31µs min=63.72µs med=114.43µs max=825.81µs p(90)=150.33µs p(95)=191.61µs |
| http_req_tls_handshaking | avg=0s min=0s med=0s max=0s p(90)=0s p(95)=0s |
| http_req_waiting | avg=618.77ms min=421.58ms med=621.32ms max=812.7ms p(90)=691.81ms p(95)=710.93ms |
| http_reqs | 188 3.106853/s |
| iteration_duration | avg=625.32ms min=427.15ms med=628.41ms max=818.77ms p(90)=698.25ms p(95)=717.76ms |
| iterations | 188 3.106853/s |
| vus | 2 min=1 max=2 |
| vus_max | 2 min=2 max=2 |
