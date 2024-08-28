#!/usr/bin/env python3

import os


class Constants:
    """
        Class to hold test constant values.
    """

    NAMESPACE = os.environ.get('kubernetes_namespace')

    IS_TLS_ENABLED = True if os.environ.get('sip_tls') and os.environ.get('sip_tls').lower() == 'true' else False  # test-framework lowers case

    SCHEMA_REGISTRY_NAME = 'eric-oss-schema-registry-sr'
    SCHEMA_REGISTRY_BASELINE_RELEASE_NAME = os.environ.get('baseline_chart_name')

    SCHEMA_REGISTRY_BASELINE_VERSION = os.environ.get('baseline_chart_version')

    SCHEMA_REGISTRY_SETTINGS = {
        'global.security.tls.enabled': str(IS_TLS_ENABLED).lower(),
        'messagebuskf.minBrokers': '1',
        'messageBus.minBrokers': '1',
        'init.minNumberOfBrokers': '1',   # backward compatibility < 1.1.4-3
        'jmx.enabled': True,
        'service.endpoints.schemaregistry.tls.enforced': 'optional'
    }

    SCHEMA_REGISTRY_CHART_ARCHIVE = f'{SCHEMA_REGISTRY_NAME}-{SCHEMA_REGISTRY_BASELINE_VERSION}.tgz'

    SCHEMA_REGISTRY_DROP_REPO = 'https://arm.seli.gic.ericsson.se/artifactory/proj-ec-son-drop-helm'

    REPO_NAME_GS = 'GS_ALL'

    KAFKA_TOPIC = 'nose_test_topic_p1_r3_pw'
    KAFKA_URL = 'eric-data-message-bus-kf-client'

    TLS_SCHEMA_REGISTRY_CERTIFICATE_FILE_NAME = '/sr-cert.pem'
    TLS_SCHEMA_REGISTRY_KEY_FILE_NAME = '/sr-privkey.pem'
    TLS_KAFKA_CERTIFICATE_FILE_NAME = 'kf-cert.pem'
    TLS_KAFKA_KEY_FILE_NAME = 'kf-privkey.pem'
    TLS_INGRESS_CERTIFICATE_FILE_NAME = 'ingress-cert.pem'
    TLS_INGRESS_KEY_FILE_NAME = 'ingress-privkey.pem'

    ROOT_CERTIFICATE_FILE_NAME = '/root-cert.pem'

    MESSAGES_TO_PRODUCE = 50

    JMX_PORT = 21000

    METRICS_MINIMUM = 800
    METRICS_JAVA_MINIMUM = 200
