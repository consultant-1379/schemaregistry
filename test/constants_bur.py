#!/usr/bin/env python3

import os


class ConstantsBUR:
    """
        Class to hold test constant values.
    """

    NAMESPACE = os.environ.get('kubernetes_namespace')

    IS_TLS_ENABLED = True if os.environ.get('sip_tls') and os.environ.get('sip_tls').lower() == 'true' else False  #
    # test-framework lowers case

    SCHEMA_REGISTRY_NAME = 'eric-oss-schema-registry-sr'

    SCHEMA_REGISTRY_BASELINE_RELEASE_NAME = os.environ.get('baseline_chart_name')

    SCHEMA_REGISTRY_BASELINE_VERSION = os.environ.get('baseline_chart_version')

    SCHEMA_REGISTRY_CHART_ARCHIVE = f'{SCHEMA_REGISTRY_NAME}-{SCHEMA_REGISTRY_BASELINE_VERSION}.tgz'

    SCHEMA_REGISTRY_DROP_REPO = 'https://arm.seli.gic.ericsson.se/artifactory/proj-ec-son-drop-helm'

    SCHEMA_REGISTRY_AGENT_CHART_INSTALL_SETTINGS = {
        'global.security.tls.enabled': str(IS_TLS_ENABLED).lower(),
        'brAgent.enabled': 'true',
        'messagebuskf.minBrokers': '1',
        'messageBus.minBrokers': '1',
        'init.minNumberOfBrokers': '1',  # backward compatibility < 1.1.4-3
        'jmx.enabled': False
    }

    BRO_NAME = 'eric-ctrl-bro'

    BRO_PROTOCOL = 'http'
    BRO_PORT = '7001'
    BACKUP_WAIT_TIME_FOR_SUCCESS_IN_SEC = 5
    BACKUP_RETRY_FOR_SUCCESS = 10
