---
description: >-
  The OpenHIM Platform includes a number of base packages which are useful for
  supporting Health Information Exchanges Workflows. Each section below
  describes the details of these packages.
---

# 📦 Packages

Package can be stood up individually using the `instant package init -n <package_name>` command, or they can be included in your own recipes. This can be accomplished by [creating a profile](https://app.gitbook.com/s/TwrbQZir3ZdvejunAFia/getting-started/config#launching-a-profile) that includes the necessary packages and any custom configuration packages.

## Performance Testing

The performance scripts are located in the `test` folder. To run this script against a local or remote server, you can follow these steps:

1. Make sure you have the necessary dependencies installed.More importantly the `k6` binary.

2. Set the [`BASE_URL`] variable to the URL of your server. By default, it is set to `"http://localhost:5001"`, but you can change it to the appropriate URL.

3. If there are any additional dependencies or configurations required by the [`generateBundle`] function or any other imported modules, make sure those are set up correctly.

4. Open your terminal or command prompt and navigate to the directory where the scripts are located e.g [`load.js`]("/media/platform/test/performance/scripts/load.js")

5. Run the script using the `k6 run` command followed by the filename. In this case, you would run [`k6 run load.js`]

6. The script will start executing and sending HTTP POST requests to the specified server. The requests will be sent at a constant arrival rate defined in the [`options`] object

7. The script includes some thresholds defined in the [`options`] object. These thresholds define the performance criteria for the script. If any of the thresholds are exceeded, the script will report a failure.

8. Monitor the output in the terminal to see the results of the script execution. It will display information such as the number of virtual users (VUs), request statistics, and any failures that occurred.

9. To visualize the output in grafana run the `k6` scripts with the following environment variables and flag set `K6_PROMETHEUS_RW_SERVER_URL=http://localhost:9090/api/v1/write && ./k6 run -o experimental-prometheus-rw script.js`
