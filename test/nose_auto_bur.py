#!/usr/bin/env python3

import time
import json
import unittest

import requests

from parameterized import parameterized
from requests import codes

import helm3procs as helmprocs
import utilprocs
from constants_bur import ConstantsBUR
from environment import Environment

test_parameters = [
    Environment.get_test_environment_parameters(tls_enabled=False)
]


class NoseAutoTests(unittest.TestCase):
    backup_name = 'TEST_BACKUP'
    backup_id = ''
    restore_id = ''

    def test_02_sr_and_br_agent_installed(self):
        utilprocs.log('Starting SR installation with Backup and Restore Agent')

        helmprocs.helm_install_chart_archive_with_dict(name=ConstantsBUR.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
                                                       namespace_name=ConstantsBUR.NAMESPACE,
                                                       chart_archive=ConstantsBUR.SCHEMA_REGISTRY_CHART_ARCHIVE,
                                                       settings_dict=ConstantsBUR.SCHEMA_REGISTRY_AGENT_CHART_INSTALL_SETTINGS,
                                                       timeout=600)

        helmprocs.helm_wait_for_deployed_release_to_appear(
            expected_release_name=ConstantsBUR.SCHEMA_REGISTRY_BASELINE_RELEASE_NAME,
            target_namespace_name=ConstantsBUR.NAMESPACE)

    @parameterized.expand(test_parameters)
    def test_03_add_schema(self, test_name, protocol, port, kafka_topic, schema_registry_certificates):
        url = f'{protocol}://{ConstantsBUR.SCHEMA_REGISTRY_NAME}:{port}/subjects/{kafka_topic}/versions'

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

        utilprocs.log(f'Sending POST request with url: {url}, payload: {payload} ')
        response = requests.post(url, data=json.dumps(payload), headers=headers)

        self.assertEqual(response.status_code, codes.ok)
        utilprocs.log(f'Added schema with id: {response.text}')

    @parameterized.expand(test_parameters)
    def test_04_schema_was_added(self, test_name, protocol, port, kafka_topic, schema_registry_certificates):
        url = f'{protocol}://{ConstantsBUR.SCHEMA_REGISTRY_NAME}:{port}/subjects'
        headers = {
            'Accept': 'application/json'
        }

        utilprocs.log(f'Sending GET request with url: {url}')
        response = requests.get(url, headers=headers)

        self.assertEqual(response.status_code, codes.ok)
        self.assertIn(kafka_topic, response.text)

        utilprocs.log(f'Schema Registry has schemas: {response.text}')

    def test_05_backup_started(self):
        utilprocs.log(f'Start to create backup')
        url = f'{ConstantsBUR.BRO_PROTOCOL}://{ConstantsBUR.BRO_NAME}:{ConstantsBUR.BRO_PORT}/v1/backup-manager' \
              f'/DEFAULT/action'
        headers = {
            'Content-Type': 'application/json'
        }
        payload = '{"action": "CREATE_BACKUP", "payload": {"backupName": "' + NoseAutoTests.backup_name + '"}}'

        utilprocs.log(f'Sending POST request with url: {url}, payload: {payload} ')

        response = requests.post(url, headers=headers, data=payload)
        response.raise_for_status()

        utilprocs.log(f'Result: {format(response)}')
        self.assertEqual(response.status_code, codes.created)

        utilprocs.log(f'Backup has been created with response: {response.json()}')

        NoseAutoTests.backup_id = response.json()['id']

        utilprocs.log(f'Backup id received: {NoseAutoTests.backup_id}')

    def test_06_backup_finished(self):
        utilprocs.log(f'Start to check status of backup: {NoseAutoTests.backup_id}')
        url = f'{ConstantsBUR.BRO_PROTOCOL}://{ConstantsBUR.BRO_NAME}:{ConstantsBUR.BRO_PORT}/v1/backup-manager' \
              f'/DEFAULT/action/{NoseAutoTests.backup_id}'

        headers = {
            'Content-Type': 'application/json'
        }
        current_try = 1
        while True:

            utilprocs.log(f'Sending GET request to url: {url}')
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            utilprocs.log(f'Result: {format(response)}')
            utilprocs.log(f'Response received: {response.json()}')

            backup_result = response.json()['state']

            if backup_result == 'FINISHED' or current_try > ConstantsBUR.BACKUP_RETRY_FOR_SUCCESS:
                utilprocs.log(f'Waiting to finish the backup ended with result: {backup_result}')
                break
            else:
                current_try = current_try + 1
                utilprocs.log(f'Waiting to finish the backup, current try: {current_try} out of '
                              f'{str(ConstantsBUR.BACKUP_RETRY_FOR_SUCCESS)}')
                time.sleep(ConstantsBUR.BACKUP_WAIT_TIME_FOR_SUCCESS_IN_SEC)

        self.assertEqual(backup_result, 'FINISHED')

    @parameterized.expand(test_parameters)
    def test_07_delete_schemas(self, test_name, protocol, port, kafka_topic, schema_registry_certificates):
        url = f'{protocol}://{ConstantsBUR.SCHEMA_REGISTRY_NAME}:{port}/subjects/{kafka_topic}'

        response = requests.delete(url)

        self.assertEqual(response.status_code, codes.ok)
        utilprocs.log(f'Deleted schema with id: {response.text}')

    @parameterized.expand(test_parameters)
    def test_08_schemas_are_empty(self, test_name, protocol, port, kafka_topic, schema_registry_certificates):
        url = f'{protocol}://{ConstantsBUR.SCHEMA_REGISTRY_NAME}:{port}/subjects'
        headers = {
            'Accept': 'application/json'
        }

        response = requests.get(url, headers=headers)

        self.assertEqual(response.status_code, codes.ok)
        self.assertIn('[]', response.text)

        utilprocs.log(f'Schema Registry has schemas: {response.text}')

    def test_09_restore_started(self):
        utilprocs.log(f'Start to restore backup')
        url = f'{ConstantsBUR.BRO_PROTOCOL}://{ConstantsBUR.BRO_NAME}:{ConstantsBUR.BRO_PORT}/v1/backup-manager' \
              f'/DEFAULT/action'

        headers = {
            'Content-Type': 'application/json'
        }
        payload = '{"action": "RESTORE", "payload": {"backupName": "' + NoseAutoTests.backup_name + '"}}'

        utilprocs.log(f'Sending POST request with url: {url}, payload: {payload} ')

        response = requests.post(url, headers=headers, data=payload)
        utilprocs.log(f'Response received: {response.json()}')

        self.assertEqual(response.status_code, codes.created)

        NoseAutoTests.restore_id = response.json()['id']
        utilprocs.log(f'Restore id received: {NoseAutoTests.restore_id}')

    def test_10_restore_finished(self):
        utilprocs.log(f'Start to check status of restore: {NoseAutoTests.restore_id}')
        url = f'{ConstantsBUR.BRO_PROTOCOL}://{ConstantsBUR.BRO_NAME}:{ConstantsBUR.BRO_PORT}/v1/backup-manager' \
              f'/DEFAULT/action/{NoseAutoTests.restore_id}'

        headers = {
            'Content-Type': 'application/json'
        }
        current_try = 1

        while True:

            utilprocs.log(f'Sending GET request to url: {url}')
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            utilprocs.log(f'Result: {format(response)}')
            utilprocs.log(f'Response received: {response.json()}')

            backup_result = response.json()['state']

            if backup_result == 'FINISHED' or current_try > ConstantsBUR.BACKUP_RETRY_FOR_SUCCESS:
                utilprocs.log(f'Waiting to finish the restore ended with result: {backup_result}')
                break
            else:
                current_try = current_try + 1
                utilprocs.log(f'Waiting to finish the restore, current try: {current_try} out of '
                              f'{str(ConstantsBUR.BACKUP_RETRY_FOR_SUCCESS)}')
                time.sleep(ConstantsBUR.BACKUP_WAIT_TIME_FOR_SUCCESS_IN_SEC)

        self.assertEqual(backup_result, 'FINISHED')

    @parameterized.expand(test_parameters)
    def test_11_schema_restored(self, test_name, protocol, port, kafka_topic, schema_registry_certificates):
        url = f'{protocol}://{ConstantsBUR.SCHEMA_REGISTRY_NAME}:{port}/subjects'
        headers = {
            'Accept': 'application/json'
        }

        response = requests.get(url, headers=headers)

        self.assertEqual(response.status_code, codes.ok)
        self.assertIn(kafka_topic, response.text)

        utilprocs.log(f'Schema Registry has schemas: {response.text}')
