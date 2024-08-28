# Copyright (c) 2021 Ericsson AB.
# All rights reserved.

ARG OS_BASE_IMAGE_REPO
ARG OS_BASE_IMAGE_NAME
ARG OS_BASE_IMAGE_TAG

FROM ${OS_BASE_IMAGE_REPO}/${OS_BASE_IMAGE_NAME}:${OS_BASE_IMAGE_TAG}

ARG OS_BASE_IMAGE_NAME
ARG OS_BASE_IMAGE_TAG
ARG CBO_REPO=https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os
ARG CBO_REPO_NAME=LDC-CBO-SLES
ARG CBO_REPO_URL=${CBO_REPO}/${OS_BASE_IMAGE_NAME}/${OS_BASE_IMAGE_TAG}
ARG USER_ID=105656
ARG USER_NAME="schema_registry_user"

LABEL GIT_COMMIT=commitid

ARG PRODUCT_REVISION
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_VERSION
LABEL com.ericsson.product-number="CXPNumber" \
com.ericsson.product-revision=$PRODUCT_REVISION \
org.opencontainers.image.title="Schema Registry SR BrAgent" \
org.opencontainers.image.created=$IMAGE_CREATED \
org.opencontainers.image.revision=$IMAGE_REVISION \
org.opencontainers.image.vendor="Ericsson" \
org.opencontainers.image.version=$IMAGE_VERSION

COPY target/bragent-1.0.1-SNAPSHOT.jar /bragent/bragent.jar
COPY entrypoint.sh /bragent/

RUN echo "$USER_ID:x:$USER_ID:0:An Identity for $USER_NAME:/nonexistent:/bin/false" >>/etc/passwd
RUN echo "$USER_ID:!::0:::::" >>/etc/shadow

COPY files/*  /bragent/scripts/

RUN zypper addrepo --no-check --no-gpgcheck --refresh ${CBO_REPO_URL}?ssl_verify=no ${CBO_REPO_NAME} \
    && zypper --non-interactive refresh --force --repo ${CBO_REPO_NAME} \
    && zypper in  --no-recommends --auto-agree-with-licenses --no-confirm java-11-openjdk-headless shadow util-linux
RUN ["/usr/bin/sh", "-c", "chmod +x /bragent/scripts/*.sh"]
RUN ["chmod", "+x", "/bragent/entrypoint.sh"]
RUN ["mkdir", "/backupdata"]
RUN ["chown", "105656", "/backupdata"]

USER $USER_ID
ENTRYPOINT ["/bragent/entrypoint.sh"]
