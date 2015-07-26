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

# A script to update sources within thedocker environment an rebuild/install aurora components.
# Usage: aurora_docker_build [COMPONENT]...
# where COMPONENT is a name for an aurora component that makes up part of the infrastructure.
# Run with zero arguments for a full list of components that may be built.
set -o nounset
set -ex

DIST_DIR=dist
AURORA_HOME=/usr/local/aurora
SCRIPT_ROOT=$(pwd)
MESOS_PKG_VERSION=0.22.0
BUILD_PACKAGES=1

function build_client {
  $SCRIPT_ROOT/pants binary src/main/python/apache/aurora/client/cli:kaurora
}

function build_admin_client {
  $SCRIPT_ROOT/pants binary src/main/python/apache/aurora/admin:kaurora_admin
}

function build_scheduler {
  $SCRIPT_ROOT/gradlew installApp
}

function build_executor {
  $SCRIPT_ROOT/pants binary src/main/python/apache/aurora/executor/bin:thermos_executor
  $SCRIPT_ROOT/pants binary src/main/python/apache/thermos/bin:thermos_runner

  # Package runner within executor.
  python <<EOF
import contextlib
import zipfile
with contextlib.closing(zipfile.ZipFile('dist/thermos_executor.pex', 'a')) as zf:
  zf.writestr('apache/aurora/executor/resources/__init__.py', '')
  zf.write('dist/thermos_runner.pex', 'apache/aurora/executor/resources/thermos_runner.pex')
EOF

  chmod +x ${DIST_DIR}/thermos_executor.pex
}

function build_observer {
  $SCRIPT_ROOT/pants binary src/main/python/apache/thermos/observer/bin:thermos_observer
}

function build_all {
  if [ ! -d third_party ]; then
    mkdir -p third_party
    pushd .
    cd third_party
    curl -O https://svn.apache.org/repos/asf/aurora/3rdparty/ubuntu/trusty64/python/mesos.native-${MESOS_PKG_VERSION}-py2.7-linux-x86_64.egg
    popd
  fi

  build_admin_client
  build_client
  build_executor
  build_observer
  build_scheduler
}

build_all $BUILD_PACKAGES
exit 0
