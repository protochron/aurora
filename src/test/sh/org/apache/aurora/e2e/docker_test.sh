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

# Run the end to end tests using Docker containers

docker_build() {
  export LOCAL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  # Build containers
  docker build -t aurora/base $DIR
  docker build -t aurora/build $DIR
  docker build -t aurora/run $DIR

  # Run containers
  DOCKER_ID=$(docker run -d --name aurora-mesos aurora/base)
  docker run --rm -v /aurora:/aurora aurora/build
  docker run -d -P --name aurora --link aurora-mesos \
    -v /aurora:aurora aurora/run
}


docker_build

source test_end_to_end.sh
