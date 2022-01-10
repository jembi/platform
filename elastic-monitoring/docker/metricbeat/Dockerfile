FROM docker.elastic.co/beats/metricbeat:7.14.1
COPY metricbeat.yml /usr/share/metricbeat/metricbeat.yml
USER root
RUN chown root /usr/share/metricbeat/metricbeat.yml
RUN chmod go-w /usr/share/metricbeat/metricbeat.yml
RUN find ./kibana/7/dashboard/ -type f | grep -v "kafka\|postgresql\|docker\|host-overview\|system-overview\|mongo" | xargs rm -v
