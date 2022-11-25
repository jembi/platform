FROM hapiproject/hapi:v5.7.0

# Copy the static shell into base image
COPY --from=busybox /bin/sh /bin/sh
# Copy all necessary executables into distroless image
COPY --from=busybox /bin/wget /bin/wget


