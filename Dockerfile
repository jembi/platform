FROM openhie/package-base:2.2.0

# Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64 -o /usr/bin/yq
RUN chmod +x /usr/bin/yq

# Install jq
RUN apt-get install jq -y 1>/dev/null
# Install envsubst
RUN apt-get install gettext-base -y 1>/dev/null

ADD . .
