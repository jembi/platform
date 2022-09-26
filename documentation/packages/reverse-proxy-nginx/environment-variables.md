---
description: >-
  Listed in this page are all environment variables needed to run Reverse Proxy
  Nginx.
---

# Environment Variables

| Variable Name             | Type   | Relevance                                         | Required | Default   |
| ------------------------- | ------ | ------------------------------------------------- | -------- | --------- |
| DOMAIN\_NAME              | String | Domain name                                       | Yes      | localhost |
| SUBDOMAINS                | String | Subdomain names                                   | Yes      |           |
| RENEWAL\_EMAIL            | String | Renewal email                                     | Yes      |           |
| REVERSE\_PROXY\_INSTANCES | Number | Number of instances                               | No       | 1         |
| STAGING                   | String | Generate fake or real certificate (true for fake) | No       | false     |
| NGINX\_CPU\_LIMIT         | Number | CPU usage limit                                   | No       | 0         |
| NGINX\_CPU\_RESERVE       | Number | Reserved CPU                                      | No       | 0.05      |
| NGINX\_MEMORY\_LIMIT      | String | RAM usage limit                                   | No       | 3G        |
| NGINX\_MEMORY\_RESERVE    | String | Reserved RAM                                      | No       | 500M      |
