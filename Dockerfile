FROM debian:stretch-slim
MAINTAINER zebra-lucky <zebra.lucky@gmail.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /dash

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
RUN groupadd -g ${GROUP_ID} dash
RUN useradd -u ${USER_ID} -g dash -s /bin/bash -m -d /dash dash

RUN chown dash:dash -R /dash

RUN apt-get update && apt-get install -y wget \
    && download_url=https://github.com/dashpay/dash/releases/download/ \
    && version=0.14.0.4 \
    && version_path=v${version}/ \
    && tar_file=dashcore-${version}-x86_64-linux-gnu.tar.gz \
    && sum=15d111f4de3f49a67dba879d680b690c941f86ad2e65e3b6b3b9b57eb37d1b42 \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp/ \
    && wget ${download_url}${version_path}${tar_file} \
    && echo $sum $tar_file | sha256sum -c \
    && tar -xzvf dashcore-*-x86_64-linux-gnu.tar.gz \
    && cp /tmp/dashcore-*/bin/*  /usr/local/bin \
    && cp /tmp/dashcore-*/lib/*  /usr/local/lib \
    && rm -rf /tmp/dashcore-*

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# For some reason, docker.io (0.9.1~dfsg1-2) pkg in Ubuntu 14.04 has permission
# denied issues when executing /bin/bash from trusted builds.  Building locally
# works fine (strange).  Using the upstream docker (0.11.1) pkg from
# http://get.docker.io/ubuntu works fine also and seems simpler.
USER dash

VOLUME ["/dash"]

EXPOSE 19998 19999

WORKDIR /dash

CMD ["dash_oneshot"]
