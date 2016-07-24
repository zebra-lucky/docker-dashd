FROM phusion/baseimage:0.9.18
MAINTAINER Holger Schinzel <holger@dash.org>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 44AFED48 && \
    echo "deb http://ppa.launchpad.net/dash.org/dash/ubuntu trusty main" > /etc/apt/sources.list.d/dash.list

RUN apt-get update && \
    apt-get install -y dashd && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME /dash
RUN useradd -s /bin/bash -m -d /dash dash
RUN chown dash:dash -R /dash

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

