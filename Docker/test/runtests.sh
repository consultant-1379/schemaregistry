#!/bin/bash

echo $1
/tmp/structure-test -test.v -image $1 Docker/test/metadata_tests.yaml
/tmp/structure-test -test.v -image $1 Docker/test/file_tests.yaml
