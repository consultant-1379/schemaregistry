#!/bin/bash

set -ex
wget https://storage.googleapis.com/container-structure-test/v0.3.0/container-structure-test \
&& mv container-structure-test structure-test \
&& mv structure-test /tmp \
&& chmod +x /tmp/structure-test
