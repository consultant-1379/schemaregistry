# Copyright (c) 2021 Ericsson AB.
# All rights reserved.

ARG CBOS_IMAGE_TAG
ARG CBOS_IMAGE_REPO
ARG CBOS_IMAGE_NAME

FROM armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles:6.16.0-13
ARG CBOS_IMAGE_TAG
ARG CBOS_REPO_URL=https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/6.16.0-13

#ARG OS_BASE_IMAGE_NAME
#ARG OS_BASE_IMAGE_TAG
ARG CBO_REPO=https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os
ARG CBO_REPO_NAME=LDC-CBO-SLES
ARG CBO_REPO_URL=https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/6.16.0-13
ARG SUSE_REPO_NAME=SUSE-REPO
ARG SUSE_REPO_URL=http://download.opensuse.org/distribution/leap/15.0/repo/oss/
ARG NEXUS_URL=https://arm1s11-eiffel112.eiffel.gic.ericsson.se:8443/nexus/content/repositories/eson-3pp/io/confluent/kafka-schema-registry/schema-registry

LABEL GIT_COMMIT=unknown

ARG JAR_FILE
ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
LABEL \
    org.opencontainers.image.title=eric-oss-schema-registry-jsb \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision="${RSTATE}" \
    com.ericsson.product-number="$IMAGE_PRODUCT_NUMBER"

# Set env variables so that it's available in derived images
ENV COMPONENT=schema-registry \
    COMPONENT_VERSION=7.3.1 \
# Used in init.sh to test Kafka readiness
    CUB_CLASSPATH=/etc/confluent/docker/docker-utils-7.3.1-jar-with-dependencies.jar \
# This affects how strings in Java class files are interpreted. We want UTF-8.
    LANG="en_US.UTF-8"

# Create schema_registry_user
#RUN echo "schema_registry_user:x:105656:105656:An Identity for eric-oss-schema-registry-sr:/etc/${COMPONENT}:/bin/bash" >> /etc/passwd
#RUN echo "105656:!::0:::::" >> /etc/shadow

# Install required tools
RUN zypper addrepo --no-check --no-gpgcheck --refresh ${CBO_REPO_URL}?ssl_verify=no ${CBO_REPO_NAME} \
    && zypper refresh --force --repo ${CBO_REPO_NAME} \
    && zypper addrepo --no-check --no-gpgcheck --refresh ${SUSE_REPO_URL}?ssl_verify=no ${SUSE_REPO_NAME} \
    && zypper refresh --force --repo ${SUSE_REPO_NAME} \
# Installing curl, openjdk
    && zypper install --auto-agree-with-licenses --no-confirm --no-recommends \
        curl \
        java-1_8_0-openjdk-headless \
        zip

ARG USER_ID=105656
ARG USER_NAME="schema_registry_user"

# Setting up Schema Registry dirs
COPY include/etc/confluent/docker /etc/confluent/docker
RUN mkdir /etc/${COMPONENT} \
    && cd /etc/${COMPONENT} \
    && curl --location --remote-name --silent ${NEXUS_URL}/${COMPONENT_VERSION}/${COMPONENT}-${COMPONENT_VERSION}.jar

# Copy stdout-redirect binary for logging
COPY stdout-redirect /stdout-redirect

# Setting up privileges
RUN chmod 705 /etc/confluent/docker/*.sh \
    && chmod 604 /etc/confluent/docker/docker-utils-7.3.1-jar-with-dependencies.jar \
    && chmod 705 /etc/${COMPONENT}/${COMPONENT}-${COMPONENT_VERSION}.jar \
    && chmod 705 /etc/${COMPONENT}/* \
    && chown $USER_ID /etc/${COMPONENT}/* \
	&& chown $USER_ID /etc/confluent/docker/* \
	&& chown $USER_ID /stdout-redirect \
    && chmod 705 /stdout-redirect


# Remove unwanted software and tidy up.
RUN rm --recursive --force /tmp/* \
    && zypper clean --all \
    && zypper removerepo ${SUSE_REPO_NAME} \
    && zypper removerepo ${CBO_REPO_NAME} \
    && zypper --non-interactive remove zip \
    && rm --recursive --force /var/log/zypper.log


RUN echo "$USER_ID:x:$USER_ID:0:An Identity for $USER_NAME:/nonexistent:/bin/false" >>/etc/passwd
RUN echo "$USER_ID:!::0:::::" >>/etc/shadow
USER $USER_ID

VOLUME ["/etc/${COMPONENT}/secrets"]
VOLUME ["/etc/${COMPONENT}/init"]

#USER schema_registry_user
WORKDIR /
ENTRYPOINT ["/bin/bash"]