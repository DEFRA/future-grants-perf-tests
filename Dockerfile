FROM defradigital/cdp-perf-test-docker:latest

WORKDIR /opt/perftest

# Copy test scenarios and configuration
COPY scenarios/ ./scenarios/
COPY entrypoint.sh .
COPY user.properties .

# Copy pre-generated session cookies and test data
# Cookies are generated during CI build with network access
COPY data/ ./data/

ENV S3_ENDPOINT=https://s3.eu-west-2.amazonaws.com
ENV TEST_SCENARIO=cw-journey-complete

ENTRYPOINT [ "./entrypoint.sh" ]
