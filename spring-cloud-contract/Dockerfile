FROM armdocker.rnd.ericsson.se/proj-eric-oss-dev-test/springcloud/spring-cloud-contract:3.1.2

ARG PROJECT_GROUP
ARG PROJECT_NAME
ARG PROJECT_VERSION
ARG PRODUCER_STUBS_CLASSIFIER
ARG APPLICATION_BASE_URL

ENV PROJECT_GROUP=${PROJECT_GROUP:-com.ericsson.oss.dmi}
ENV PROJECT_NAME=${PROJECT_NAME:-eric-oss-schema-registry-sr}
ENV PROJECT_VERSION=${PROJECT_VERSION:-1.0.0-0}
ENV PRODUCER_STUBS_CLASSIFIER=${PRODUCER_STUBS_CLASSIFIER:-stubs}
ENV APPLICATION_BASE_URL=${APPLICATION_BASE_URL:-http://eric-oss-schema-registry-sr:8081}
ENV PUBLISH_ARTIFACTS=false

USER scc:scc

COPY contracts/ /contracts/

WORKDIR /spring-cloud-contract

ENTRYPOINT ["tail", "-f", "/dev/null"]
