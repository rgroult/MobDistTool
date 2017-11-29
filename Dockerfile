FROM google/dart-runtime:1.21

RUN  apt-get -q update && apt-get install -q -y aapt && rm -rf /var/lib/apt/lists/*