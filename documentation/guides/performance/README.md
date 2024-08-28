# Performance Testing

The performance scripts are located in the [test](https://github.com/jembi/platform/tree/main/test) folder. To run this script against a local or remote server.

## Steps

1. Make sure you have the necessary dependencies installed, more importantly, the `k6` binary. Refer to this documentation [`Building a k6 binary`]("https://github.com/jembi/platform/blob/86bzwerm7/test/performance/README.md")

2. Set the [`BASE_URL`] variable to the URL of your server. By default, it is set to `"http://localhost:5001"`, but you can change it to the appropriate URL.

3. If there are any additional dependencies or configurations required by the [`generateBundle`] function or any other imported modules, make sure those are set up correctly.

4. Open your terminal or command prompt and navigate to the directory where the scripts are located e.g. [`load.js`]("/media/platform/test/performance/scripts/load.js")

5. Run the script using the `k6 run` command followed by the filename. In this case, you would run [`k6 run load.js`]

6. The script will start executing and sending HTTP POST requests to the specified server. The requests will be sent at a constant arrival rate defined in the [`options`] object

7. The script includes some thresholds defined in the [`options`] object. These thresholds define the performance criteria for the script. If any of the thresholds are exceeded, the script will report a failure.

8. Monitor the output in the terminal to see the results of the script execution. It will display information such as the number of virtual users (VUs), request statistics, and any failures that occurred.

9. To visualize the output in grafana run the `k6` scripts with the following environment variables and flag set `K6_PROMETHEUS_RW_SERVER_URL=http://localhost:9090/api/v1/write && ./k6 run -o experimental-prometheus-rw script.js`

## Sample load test result

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

## Sample volume test results

| Metric                   | Value                                                                           |
| ------------------------ | ------------------------------------------------------------------------------- |
| checks                   | 100.00% ✓ 954 ✗ 0                                                               |
| data_received            | 12 MB 40 kB/s                                                                   |
| data_sent                | 20 MB 66 kB/s                                                                   |
| dropped_iterations       | 23345 77.340364/s                                                               |
| http_req_blocked         | avg=7.44µs min=2.89µs med=5.34µs max=235.67µs p(90)=7.39µs p(95)=8.49µs         |
| http_req_connecting      | avg=1.14µs min=0s med=0s max=180.71µs p(90)=0s p(95)=0s                         |
| http_req_duration        | avg=2.49s min=478.77ms med=2.5s max=3.22s p(90)=2.7s p(95)=2.79s                |
| http_req_failed          | 0.00% ✓ 0 ✗ 954                                                                 |
| http_req_receiving       | avg=105.4µs min=51.79µs med=103.68µs max=473.23µs p(90)=129.93µs p(95)=140.63µs |
| http_req_sending         | avg=130.4µs min=60.02µs med=110.82µs max=2.72ms p(90)=152.04µs p(95)=225.79µs   |
| http_req_tls_handshaking | avg=0s min=0s med=0s max=0s p(90)=0s p(95)=0s                                   |
| http_req_waiting         | avg=2.49s min=478.52ms med=2.5s max=3.22s p(90)=2.7s p(95)=2.79s                |
| http_reqs                | 954 3.160536/s                                                                  |
| iteration_duration       | avg=2.5s min=483.16ms med=2.5s max=3.23s p(90)=2.7s p(95)=2.79s                 |
| iterations               | 954 3.160536/s                                                                  |
| vus                      | 4 min=4 max=8                                                                   |
| vus_max                  | 8 min=7 max=8                                                                   |
