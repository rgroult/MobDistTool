
### FROM GOOGLE/DART_BASE
# https://github.com/dart-lang/dart_docker/blob/master/base/Dockerfile.template

FROM gcr.io/google-appengine/debian9
ENV DART_VERSION 1.21.1

# gnupg2: https://stackoverflow.com/questions/50757647
RUN \
  apt-get -q update && apt-get install --no-install-recommends -y -q gnupg2 curl git ca-certificates apt-transport-https openssh-client
  # curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  # curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
  # curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list && \
  # apt-get update && \
  # apt-get install dart=$DART_VERSION && \
  #rm -rf /var/lib/apt/lists/*

  ## Force install dart version 1.21
  RUN curl https://storage.googleapis.com/download.dartlang.org/linux/debian/pool/main/d/dart/dart_1.21.1-1_amd64.deb > dart_1.21.1-1_amd64.deb && dpkg -i ./dart_1.21.1-1_amd64.deb 

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH

### FROM GOOGLE/RUNTIME_BASE
# https://github.com/dart-lang/dart_docker/blob/master/runtime-base/Dockerfile.template

ADD dart_run.sh /dart_runtime/
RUN chmod 755 /dart_runtime/dart_run.sh && \
  chown root:root /dart_runtime/dart_run.sh

ENV PORT 8080

# Expose ports for debugger (5858), application traffic ($PORT)
# and the observatory (8181)
EXPOSE $PORT 8181 5858

CMD []
ENTRYPOINT ["/dart_runtime/dart_run.sh"]


### FROM GOOGLE/RUNTIME
# https://github.com/dart-lang/dart_docker/blob/master/runtime/Dockerfile.template

WORKDIR /app

# In docker each step creates an image layer that is cached. We add the
# pubspec.* before "pub get", then we add the rest of /app/ and run
# "pub get --offline". Thus, rebuilding without touching pubspec.* files won't
# download all dependencies again (facilitating faster image rebuilds).
ADD pubspec.* /app/
RUN pub get
ADD . /app/
RUN pub get --offline

## Add AAPT
RUN  apt-get -q update && apt-get install -q -y aapt && rm -rf /var/lib/apt/lists/*

# OLD
# FROM google/dart-runtime
# RUN  apt-get -q update && apt-get install -q -y aapt && rm -rf /var/lib/apt/lists/*