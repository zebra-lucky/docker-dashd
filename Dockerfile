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
RUN apt-get update && apt-get install -y wget vim less net-tools git python3 \
    && download_url=https://github.com/dashpay/dash/releases/download/ \
    && version=0.16.1.1 \
    && version_path=v${version}/ \
    && tar_file=dashcore-${version}-x86_64-linux-gnu.tar.gz \
    && sum=8803928bd18e9515f1254f97751eb6e537a084d66111ce7968eafb23e26bf3a5 \
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
