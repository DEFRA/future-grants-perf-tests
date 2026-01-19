FROM defradigital/cdp-perf-test-docker:latest

# Install Node.js and Chromium for cookie generation (Alpine-based)
USER root
RUN apk add --no-cache \
    nodejs \
    npm \
    chromium \
    chromium-chromedriver \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

WORKDIR /opt/perftest

# Copy test scenarios and configuration
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
