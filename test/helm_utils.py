#!/usr/bin/env python3

import helm3procs
import utilprocs
import subprocess

from constants import Constants


def retrieve_latest_pra_version() -> str:
    utilprocs.log(f'Retrieve latest PRA version of {Constants.SCHEMA_REGISTRY_NAME}')

    helm3procs.add_helm_repo(helm_repo=Constants.SCHEMA_REGISTRY_DROP_REPO,
                             helm_repo_name=Constants.SCHEMA_REGISTRY_NAME)

    utilprocs.execute_command('helm repo update')

    repository = f'{Constants.SCHEMA_REGISTRY_NAME}/{Constants.SCHEMA_REGISTRY_NAME}'
    pipeline = [f'helm search repo {repository} --versions',
                'sort --version-sort --reverse',
                'head --lines 1',
                "awk '{print $2}'"]

    command = ' | '.join(pipeline)
    utilprocs.log(f'Command executed: {command}')

    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               stdin=subprocess.PIPE)
    latest_version = process.stdout.read().decode('UTF-8').strip()

    utilprocs.log(f'Latest version available for {Constants.SCHEMA_REGISTRY_NAME} is: {latest_version}')

    return latest_version
