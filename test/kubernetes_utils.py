#!/usr/bin/env python3

import time

from kubernetes.client.api import core_v1_api

import utilprocs

api = core_v1_api.CoreV1Api()


def wait_for_pod_to_start(name, namespace, retry=60, interval=10, exception_count=60):
    """
    Waits till all the containers of the pod are ready.

    :param name: name of the pod we are checking.
    :param namespace: he namespace that the pod is in
    :param retry: amount of times it tries to check the pod, default 60
    :param interval: interval to wait between retries in seconds, default 10
    :param exception_count: amount of times it tries to reach the pod, default 60
    """

    utilprocs.log(f'Waiting for Pod: {name}')
    utilprocs.log(f'Maximum time to wait is {retry * interval}s')

    while True:
        try:
            api_response = api.read_namespaced_pod(name, namespace)
        except Exception as e:
            utilprocs.log(f'Exception when trying to find pod in namespace: {e}')

            exception_count -= 1
            if exception_count <= 0:
                raise
            time.sleep(1)
            continue

        if api_response.status.phase == 'Running' and all(container_status.ready for container_status in api_response.status.container_statuses):
            utilprocs.log(f'Pod ready: {name}')
            return

        if retry > 0:
            retry -= 1
            time.sleep(interval)
        else:
            raise ValueError('Timeout waiting for pod to be ready')
