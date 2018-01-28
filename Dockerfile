# nbx/base
#
# VERSION               0.1.0

FROM ubuntu

ARG PKGSRC_BASEURL=http://d7zr21m3kwv6q.cloudfront.net
ARG PKGSRC_GONANO=nanobox/gonano/Linux
ARG PKGSRC_MAIN=2017/11/nanobox/base/Linux

LABEL name="nbx/base" version="0.1.0" maintainer="Nanobox, Inc" \
      description="The base for all official Nanobox Docker images. Most users will want to use a different nbx/* image in their projects."

SHELL ["/bin/bash", "-c"]

# Create needed directories
RUN mkdir -p \
      /etc/environment.d \
      /var/gonano/{db,run} \
      /data/var/db \
      /var/nanobox

# Install curl and wget
RUN apt-get update -qq && \
    apt-get install -y curl wget vim nano sudo net-tools netcat iproute iputils-ping netbase locales tzdata && \
    apt-get dist-upgrade --auto-remove -y && \
    apt-get clean all

# Install pkgsrc "gonano" bootstrap
RUN set -o pipefail && \
    curl -s ${PKGSRC_BASEURL}/${PKGSRC_GONANO}/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "${PKGSRC_BASEURL}/${PKGSRC_GONANO}" > /opt/gonano/etc/pkgin/repositories.conf && \
    /opt/gonano/sbin/pkg_admin rebuild && \
    rm -rf /var/gonano/db/pkgin && \
    /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in siphon && \
    rm -rf \
      /var/gonano/db/pkgin \
      /opt/gonano/share/{doc,ri,examples} \
      /opt/gonano/man

# add gonano binaries on path
ENV PATH /opt/gonano/sbin:/opt/gonano/bin:$PATH

# install pkgsrc "base" bootstrap
RUN set -o pipefail && \
    curl -s ${PKGSRC_BASEURL}/${PKGSRC_MAIN}/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "${PKGSRC_BASEURL}/${PKGSRC_MAIN}" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && \
    /data/bin/pkgin -y up && \
    rm -rf \
      /data/var/db/pkgin \
      /data/share/{doc,ri,examples} \
      /data/man

# Add gonano user
RUN mkdir -p /data/var/home && \
    groupadd gonano && \
    useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano -d /data/var/home/gonano gonano && \
    passwd -u gonano

# Copy files
COPY files/base/. /

# Own all gonano files
RUN chown -R gonano:gonano /data

# Set Permissions on the /root folder and /root/.ssh folder
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root && \
    chmod 0700 /root/.ssh

# Generate and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set terminal
ENV TERM xterm

# Cleanup disk
RUN rm -rf \
      /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/*
