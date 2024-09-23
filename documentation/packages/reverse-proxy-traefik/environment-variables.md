# Traefik Environment Variables

The following environment variables can be used to configure Traefik:

| Variable          | Value                                                                                            | Description                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------- |
| CERT_RESOLVER     | le                                                                                               | The certificate resolver to use for obtaining TLS certificates. |
| CA_SERVER         | [https://acme-v02.api.letsencrypt.org/directory](https://acme-v02.api.letsencrypt.org/directory) | The URL of the ACME server for certificate generation.          |
| TLS               | true                                                                                             | Enable or disable TLS encryption.                               |
| TLS_CHALLENGE     | http                                                                                             | The challenge type to use for TLS certificate generation.       |
| WEB_ENTRY_POINT   | web                                                                                              | The entry point for web traffic.                                |
| REDIRECT_TO_HTTPS | true                                                                                             | Enable or disable automatic redirection to HTTPS.               |
