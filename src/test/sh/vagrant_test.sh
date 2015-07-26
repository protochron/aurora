#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Determine if we are already in the vagrant environment.  If not, start it up and invoke the script
# from within the environment.

if [[ "$USER" != "vagrant" ]]; then
  vagrant up
  vagrant ssh -c /vagrant/src/test/sh/org/apache/aurora/e2e/test_end_to_end.sh "$@"
  exit $?
  readonly TEST_SCHEDULER_IP=192.168.33.7
fi

set -u -e -x
set -o pipefail

aurorabuild all

# build the test docker image
export TEST_ROOT=/vagrant/src/test/sh/org/apache/aurora/e2e
export EXAMPLE_DIR=${TEST_ROOT}/http
export DOCKER_DIR=${TEST_ROOT}/docker
sudo docker build -t http_example ${TEST_ROOT}
