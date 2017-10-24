FROM phusion/baseimage
MAINTAINER Holger Schinzel <holger@dash.org>

ARG USER_ID
ARG GROUP_ID

ENV HOME /dash

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
RUN groupadd -g ${GROUP_ID} dash
RUN useradd -u ${USER_ID} -g dash -s /bin/bash -m -d /dash dash

RUN chown dash:dash -R /dash

ADD https://github.com/zebra-lucky/dash/releases/download/v0.12.2/dash-linux-64-v0.12.2-testbuild.tgz /tmp/
RUN tar -xzvf /tmp/dash-linux-64-v0.12.2-testbuild.tgz -C /tmp/
RUN cp /tmp/dash-linux-64-v0.12.2-testbuild/bin/*  /usr/local/bin
RUN rm -rf /tmp/dash-linux-64-v0.12.2-testbuild

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# For some reason, docker.io (0.9.1~dfsg1-2) pkg in Ubuntu 14.04 has permission
# denied issues when executing /bin/bash from trusted builds.  Building locally
# works fine (strange).  Using the upstream docker (0.11.1) pkg from
# http://get.docker.io/ubuntu works fine also and seems simpler.
USER dash

VOLUME ["/dash"]

EXPOSE 9998 9999 19998 19999

WORKDIR /dash

CMD ["dash_oneshot"]
