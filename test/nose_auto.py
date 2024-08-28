#!/usr/bin/env python3

import datetime
import json
import os
import unittest
import yaml
import base64

import requests
from kubernetes.client import Configuration
from kubernetes.client.api import core_v1_api
from parameterized import parameterized
from requests import codes

import helm3procs as helmprocs
import k8sclient
import kafkaprocs
import kubernetes_utils
import siptls_helm3 as siptls
import utilprocs
from constants import Constants
from environment import Environment
from helm_utils import retrieve_latest_pra_version

test_parameters = [
    Environment.get_test_environment_parameters(tls_enabled=False)
]

if Constants.IS_TLS_ENABLED is True:
    test_parameters.append(Environment.get_test_environment_parameters(tls_enabled=True))

configuration = Configuration()
configuration.assert_hostname = False
Configuration.set_default(configuration)
kube = k8sclient.KubernetesClient()


class NoseAutoTests(unittest.TestCase):
    def test_02_install_sr(self):
        utilprocs.log('Starting SR installation')

        helmprocs.helm_install_chart_archive_with_dict(name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                       namespace_name=Constants.NAMESPACE,
                                                       chart_archive=Constants.SCHEMA_REGISTRY_CHART_ARCHIVE,
                                                       settings_dict=Constants.SCHEMA_REGISTRY_SETTINGS,
                                                       timeout=600)

        helmprocs.helm_wait_for_deployed_release_to_appear(expected_release_name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                           target_namespace_name=Constants.NAMESPACE)
        self.verify_jmx_metrics()

    def test_03_create_certificates(self):
        if Constants.IS_TLS_ENABLED:
            utilprocs.log('Retrieving root certificate')
            siptls.retrieve_sip_tls_root_cert(namespace=Constants.NAMESPACE,
                                              filename=Constants.ROOT_CERTIFICATE_FILE_NAME)

            utilprocs.log('Requesting kafka client certificate')
            kf_secret = 'nose-auto-kafka-client-cert-secret'
            siptls.create_client_cert_request(namespace=Constants.NAMESPACE,
                                              secret_name=kf_secret,
                                              cert_resource_file_name='kf-client-cert.yaml',
                                              authority='eric-data-message-bus-kf-client-client-ca')

            utilprocs.log('Mounting kafka client certificate')
            siptls.mount_certificate(namespace=Constants.NAMESPACE,
                                     secret_name=kf_secret,
                                     cert_filename=Constants.TLS_KAFKA_CERTIFICATE_FILE_NAME,
                                     key_filename=Constants.TLS_KAFKA_KEY_FILE_NAME)

            utilprocs.log('Requesting schema registry client certificate')
            sr_secret = 'nose-auto-sr-client-cert-secret'
            siptls.create_client_cert_request(namespace=Constants.NAMESPACE,
                                              secret_name=sr_secret,
                                              cert_resource_file_name='sr-client-cert.yaml',
                                              authority='eric-oss-schema-registry-sr-client-ca')

            utilprocs.log('Mounting schema registry client certificate')
            siptls.mount_certificate(namespace=Constants.NAMESPACE,
                                     secret_name=sr_secret,
                                     cert_filename=Constants.TLS_SCHEMA_REGISTRY_CERTIFICATE_FILE_NAME,
                                     key_filename=Constants.TLS_SCHEMA_REGISTRY_KEY_FILE_NAME)

            # Set environment for python requests module
            os.environ['REQUESTS_CA_BUNDLE'] = Constants.ROOT_CERTIFICATE_FILE_NAME
        else:
            utilprocs.log('TLS is disabled, skipping certificate creation')

    @parameterized.expand(test_parameters)
    def test_04_add_schema(self, name, protocol, port, kafka_topic, cert):
        url = protocol + '://' + Constants.SCHEMA_REGISTRY_NAME + ':' + port + '/subjects/' + kafka_topic + '/versions'
        headers = {
            'Content-Type': 'application/vnd.schemaregistry.v1+json',
            'Accept': 'application/json'
        }
        payload = {
            "schema": "{ \
                \"type\": \"record\", \
                \"name\": \"" + kafka_topic + "\", \
                \"namespace\": \"com.ippontech.kafkatutorials\", \
                \"fields\": [ \
                { \
                    \"name\": \"firstName\", \
                    \"type\": \"string\" \
                }, \
                { \
                    \"name\": \"lastName\", \
                    \"type\": \"string\" \
                }, \
                { \
                    \"name\": \"birthDate\", \
                    \"type\": \"long\" \
                }] \
            }"
        }

        response = requests.post(url, data=json.dumps(payload), headers=headers, cert=cert)
        response.raise_for_status()

        self.assertEqual(response.status_code, codes.ok)
        utilprocs.log(f'Added schema with id: {response.text}')

    @parameterized.expand(test_parameters)
    def test_05_list_schemas(self, name, protocol, port, kafka_topic, cert):
        url = protocol + '://' + Constants.SCHEMA_REGISTRY_NAME + ':' + port + '/subjects'
        headers = {
            'Accept': 'application/json'
        }

        response = requests.get(url, headers=headers, cert=cert)
        response.raise_for_status()

        self.assertEqual(response.status_code, codes.ok)
        self.assertIn(kafka_topic, response.text)

        utilprocs.log(f'Schema Registry has schemas: {response.text}')

    @parameterized.expand(test_parameters)
    def test_06_produce_and_consume_messages(self, name, protocol, port, kafka_topic, schema_registry_certificates):
        self.verify_produce_and_consume_messages(protocol=protocol,
                                                 port=port,
                                                 kafka_topic=kafka_topic,
                                                 schema_registry_certificates=schema_registry_certificates)

    @parameterized.expand(test_parameters)
    def test_07_downgrade(self, name, protocol, port, kafka_topic, schema_registry_certificates):
        latest_schema_registry_version = retrieve_latest_pra_version()
        utilprocs.log(f'Downgrade Schema Registry to the version of {latest_schema_registry_version}')

        helmprocs.add_helm_repo(helm_repo_name=Constants.SCHEMA_REGISTRY_NAME,
                                helm_repo=Constants.SCHEMA_REGISTRY_DROP_REPO)
        helmprocs.helm_upgrade_with_chart_repo_with_dict(helm_release_name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                         helm_chart_name=f'{Constants.SCHEMA_REGISTRY_NAME}/'
                                                                         f'{Constants.SCHEMA_REGISTRY_NAME}-'
                                                                         f'{latest_schema_registry_version}.tgz',
                                                         helm_repo_name=Constants.SCHEMA_REGISTRY_DROP_REPO,
                                                         chart_version=latest_schema_registry_version,
                                                         target_namespace_name=Constants.NAMESPACE,
                                                         settings_dict=Constants.SCHEMA_REGISTRY_SETTINGS,
                                                         timeout=600)

        self.verify_application_version(app_version=latest_schema_registry_version)
        self.verify_produce_and_consume_messages(protocol=protocol,
                                                 port=port,
                                                 kafka_topic=kafka_topic,
                                                 schema_registry_certificates=schema_registry_certificates)
        self.verify_jmx_metrics()

    @parameterized.expand(test_parameters)
    def test_08_upgrade(self, name, protocol, port, kafka_topic, schema_registry_certificates):
        utilprocs.log(f'Upgrade Schema Registry to the version of {Constants.SCHEMA_REGISTRY_BASELINE_VERSION}')

        helmprocs.helm_upgrade_with_chart_archive_with_dict(baseline_release_name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                            target_namespace_name=Constants.NAMESPACE,
                                                            chart_archive=Constants.SCHEMA_REGISTRY_CHART_ARCHIVE,
                                                            settings_dict=Constants.SCHEMA_REGISTRY_SETTINGS,
                                                            timeout=600)

        self.verify_application_version(app_version=Constants.SCHEMA_REGISTRY_BASELINE_VERSION)
        self.verify_produce_and_consume_messages(protocol=protocol,
                                                 port=port,
                                                 kafka_topic=kafka_topic,
                                                 schema_registry_certificates=schema_registry_certificates)
        self.verify_jmx_metrics()

    @parameterized.expand(test_parameters)
    def test_09_pod_delete(self, name, protocol, port, kafka_topic, schema_registry_certificates):
        utilprocs.log('Starting POD Deletion to verify auto restart')

        pods = kube.get_statefulset_pods(name=Constants.SCHEMA_REGISTRY_NAME,
                                         namespace=Constants.NAMESPACE)
        schema_registry_pod = pods[0]
        utilprocs.log(f'Name of Schema Registry pod: {schema_registry_pod}')

        start_delete = datetime.datetime.now()
        utilprocs.log(f'Deletion of {schema_registry_pod} started at: {start_delete}')

        kube.delete_pod(name=schema_registry_pod,
                        namespace=Constants.NAMESPACE)

        end_delete = datetime.datetime.now()
        utilprocs.log(f'{schema_registry_pod} deleted successfully finished at: {end_delete}')
        utilprocs.log(f'Deleting {schema_registry_pod} took: {end_delete - start_delete}')

        kubernetes_utils.wait_for_pod_to_start(name=schema_registry_pod,
                                               namespace=Constants.NAMESPACE)

        self.verify_produce_and_consume_messages(protocol=protocol,
                                                 port=port,
                                                 kafka_topic=kafka_topic,
                                                 schema_registry_certificates=schema_registry_certificates)
        self.verify_jmx_metrics()

    def test_10_install_sr_with_ingress_ca(self):
        if Constants.IS_TLS_ENABLED:
            with open("ca_common.yaml", "r") as cert_tpl:
                cert_body = cert_tpl.read()
            ca_secret_name = "test-ingres-sr-secret"
            cert_body = cert_body.replace("{name}", ca_secret_name)
            cert_body = yaml.safe_load(cert_body)

            group, version = cert_body['apiVersion'].split('/')
            plural = f"{cert_body['kind'].lower()}s"
            body = cert_body
            utilprocs.log('Starting SR installation with ingress CA')
            kube.create_custom_resource(
                Constants.NAMESPACE, group, version, plural, body
            )
            helmprocs.helm_upgrade_with_chart_archive_with_dict(baseline_release_name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                                target_namespace_name=Constants.NAMESPACE,
                                                                chart_archive=Constants.SCHEMA_REGISTRY_CHART_ARCHIVE,
                                                                settings_dict={**Constants.SCHEMA_REGISTRY_SETTINGS, **{'ingress.caCertificateSecret': ca_secret_name}},
                                                                timeout=600)
            helmprocs.helm_wait_for_deployed_release_to_appear(expected_release_name=Constants.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                               target_namespace_name=Constants.NAMESPACE)
            self.verify_jmx_metrics()
            ingress_secret = "ingress-client-cert"
            siptls.create_client_cert_request(namespace=Constants.NAMESPACE,
                                              secret_name=ingress_secret,
                                              cert_resource_file_name='ingress-client-cert.yaml',
                                              authority=ca_secret_name)
            siptls.mount_certificate(namespace=Constants.NAMESPACE,
                                     secret_name=ingress_secret,
                                     cert_filename=Constants.TLS_INGRESS_CERTIFICATE_FILE_NAME,
                                     key_filename=Constants.TLS_INGRESS_KEY_FILE_NAME)
            siptls.retrieve_sip_tls_root_cert(namespace=Constants.NAMESPACE,
                                              filename=Constants.ROOT_CERTIFICATE_FILE_NAME)
            secret = kube.get_namespace_secrets(Constants.NAMESPACE, [ca_secret_name])[0]
            cert_data = base64.b64decode(secret.data["ca.pem"])
            with open(Constants.ROOT_CERTIFICATE_FILE_NAME, "ab") as file:
                file.write("\n".encode())
                file.write(cert_data)

            url = 'https://' + Constants.SCHEMA_REGISTRY_NAME + ':8082/subjects'
            headers = {
                'Accept': 'application/json'
            }
            os.environ['REQUESTS_CA_BUNDLE'] = Constants.ROOT_CERTIFICATE_FILE_NAME
            response = requests.get(url, headers=headers, cert=(Constants.TLS_INGRESS_CERTIFICATE_FILE_NAME,
                                                                Constants.TLS_INGRESS_KEY_FILE_NAME))

            response.raise_for_status()
            self.assertEqual(response.status_code, codes.ok)
            utilprocs.log(f'Schema Registry has schemas: {response.text}')

    def verify_jmx_metrics(self):
        """
        Verifies JMX is up and running correctly.
        """

        schema_registry_ip = kube.get_pod_ip_address(name=Constants.SCHEMA_REGISTRY_NAME,
                                                     namespace=Constants.NAMESPACE)

        response = requests.get(f'http://{schema_registry_ip}:{Constants.JMX_PORT}')
        response.raise_for_status()

        self.assertEqual(codes.ok, response.status_code)

        metrics = list(filter(lambda metric: not metric.startswith('#'), response.text.splitlines()))
        utilprocs.log(f'There are #{len(metrics)} collected metrics from JMX')

        java_metrics = list(filter(lambda metric: 'java' in metric, metrics))
        utilprocs.log(f'There are #{len(java_metrics)} Java related metrics')

        if len(java_metrics) <= Constants.METRICS_JAVA_MINIMUM or len(metrics) <= Constants.METRICS_MINIMUM:
            utilprocs.log("JMX is not working properly")
            utilprocs.log(response.text)

            self.assertGreater(len(metrics), Constants.METRICS_MINIMUM, 'There should be around ~1000 metrics')
            self.assertGreater(len(java_metrics), Constants.METRICS_JAVA_MINIMUM, 'There should be around ~260 Java metrics')

        utilprocs.log("Printing Java metrics")
        for java_metric in java_metrics:
            utilprocs.log(java_metric)

    def verify_application_version(self, app_version):
        """
        Verifies the currently running application`s version.

        :param app_version: version of the application
        """

        pods = core_v1_api.CoreV1Api().list_namespaced_pod(namespace=Constants.NAMESPACE,
                                                           pretty=True,
                                                           label_selector=f'app={Constants.SCHEMA_REGISTRY_NAME}')

        self.assertTrue(len(pods.items) == 1, 'Expected only one pod to be present with the given labels')

        labels = pods.items[0].metadata.labels
        self.assertEqual(Constants.SCHEMA_REGISTRY_NAME, labels['app'])
        if 'app.kubernetes.io/version' in labels:     # old versions (< 1.1.3-5) do not have this label, PRA versions have the '+' sign substituted with '_'
            self.assertEqual(app_version.replace('+', '_'), labels['app.kubernetes.io/version'])

    def verify_produce_and_consume_messages(self, protocol, port, kafka_topic, schema_registry_certificates):
        """
        Verifies the producer - consumer mechanism works for the given Kafka topic.

        :param protocol: HTTP / HTTPS protocol
        :param port: port on which Schema Registry is listening
        :param schema_registry_certificates: certificate files for Schema Registry
        :param kafka_topic: name of the Kafka topic
        """

        kafkaprocs.produce_messages(number_of_messages=Constants.MESSAGES_TO_PRODUCE,
                                    protocol=protocol,
                                    port=port,
                                    kafka_topic=kafka_topic,
                                    schema_registry_certificates=schema_registry_certificates)

        consumed_messages = kafkaprocs.consume_messages(protocol=protocol,
                                                        port=port,
                                                        kafka_topic=kafka_topic,
                                                        schema_registry_certificates=schema_registry_certificates)
        self.assertEqual(Constants.MESSAGES_TO_PRODUCE, consumed_messages,
                         f'Produced messages {Constants.MESSAGES_TO_PRODUCE} is not equal to consumed messages {consumed_messages}')
