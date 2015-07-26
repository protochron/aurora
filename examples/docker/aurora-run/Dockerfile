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
FROM ubuntu:trusty
MAINTAINER Apache Aurora <dev@aurora.apache.org>

ENV DEBIAN_FRONTEND noninteractive
VOLUME /aurora
WORKDIR /aurora
ENV HOME /aurora
ENV MESOS_PKG_VERSION 0.22.0

RUN apt-get update && apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  iptables \
  libapr1-dev \
  libcurl4-openssl-dev \
  libsasl2-dev \
  libsvn-dev \
  lxc \
  python-dev \
  software-properties-common \
  supervisor \
  zookeeper

RUN add-apt-repository ppa:openjdk-r/ppa -y \
  && apt-get update \
  && apt-get install -y openjdk-8-jdk \
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN curl -O http://downloads.mesosphere.io/master/ubuntu/14.04/mesos_${MESOS_PKG_VERSION}-1.0.ubuntu1404_amd64.deb \
  && dpkg --install mesos_${MESOS_PKG_VERSION}-1.0.ubuntu1404_amd64.deb \
  && rm mesos_${MESOS_PKG_VERSION}-1.0.ubuntu1404_amd64.deb

RUN mkdir -p /usr/local/aurora/master/db \
  && mkdir -p /var/log/mesos

RUN curl -sSL https://get.docker.com/ubuntu/ | sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY link_apps /usr/local/bin/link_apps

EXPOSE 1338 2181 2888 3888 5050 5051 8081 8083

CMD link_apps && supervisord
