FROM defradigital/cdp-perf-test-docker:latest

# Install Node.js and Chrome for cookie generation
USER root
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/perftest

COPY scenarios/ ./scenarios/
COPY auth/ ./auth/
COPY entrypoint.sh .
COPY user.properties .
COPY data/ ./data/

# Install auth dependencies
RUN cd auth/run && npm ci && cd ../..

ENV S3_ENDPOINT=https://s3.eu-west-2.amazonaws.com
ENV TEST_SCENARIO=cw-journey-complete

ENTRYPOINT [ "./entrypoint.sh" ]
