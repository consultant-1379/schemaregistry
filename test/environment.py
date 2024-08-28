#!/usr/bin/env python3

from constants import Constants


class Environment:
    """
        Holds environment variables based on tls setting.
    """

    def __init__(self) -> None:
        self.port_kafka = '9093' if Constants.IS_TLS_ENABLED else '9092'
        self.security_protocol = 'SSL' if Constants.IS_TLS_ENABLED else 'PLAINTEXT'
        self.ssl_cafile = Constants.ROOT_CERTIFICATE_FILE_NAME if Constants.IS_TLS_ENABLED else None
        self.ssl_certfile = Constants.TLS_KAFKA_CERTIFICATE_FILE_NAME if Constants.IS_TLS_ENABLED else None
        self.ssl_keyfile = Constants.TLS_KAFKA_KEY_FILE_NAME if Constants.IS_TLS_ENABLED else None

    @staticmethod
    def get_test_environment_parameters(tls_enabled) -> tuple:
        """
            Constructs input for parameterized test calls.

            #1 test name
            #2 protocol
            #3 port
            #4 Kafka topic name
            #5 Schema Registry certificate files

            :param tls_enabled: whether TLS is enabled or not
            :return: tuple holding input for parameterized test calls
        """

        return (
            'tls_enabled' if tls_enabled is True else 'tls_disabled',
            'https' if tls_enabled else 'http',
            '8082' if tls_enabled else '8081',
            f'{Constants.KAFKA_TOPIC}_tls' if tls_enabled is True else Constants.KAFKA_TOPIC,
            (Constants.TLS_SCHEMA_REGISTRY_CERTIFICATE_FILE_NAME,
             Constants.TLS_SCHEMA_REGISTRY_KEY_FILE_NAME) if tls_enabled else None
        )
