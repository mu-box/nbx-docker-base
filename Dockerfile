# mubox/nbx-base
#
# VERSION               0.1.0

FROM ubuntu

ARG PKGSRC_BASEURL=http://s3.amazonaws.com/tools.microbox.cloud
ARG PKGSRC_GOMICRO=mubox/gomicro/Linux
ARG PKGSRC_MAIN=2017/11/microbox/base/Linux

LABEL name="mubox/nbx-base" version="0.1.0" maintainer="The Microbox Team" \
      description="The base for all official Microbox Docker images. Most users will want to use a different mubox/nbx-* image in their projects."

SHELL ["/bin/bash", "-c"]

# Create needed directories
RUN mkdir -p \
      /etc/environment.d \
      /var/gomicro/{db,run} \
      /data/var/db \
      /var/microbox

# Install curl and wget
RUN apt-get update -qq && \
    apt-get install -y \
            curl \
            iproute \
            iputils-ping \
            locales \
            nano \
            net-tools \
            netbase \
            netcat \
            sudo \
            tzdata \
            vim \
            wget \
        && \
    apt-get dist-upgrade --auto-remove -y && \
    apt-get clean all

# Install pkgsrc "gomicro" bootstrap
RUN set -o pipefail && \
    curl -s ${PKGSRC_BASEURL}/${PKGSRC_GOMICRO}/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "${PKGSRC_BASEURL}/${PKGSRC_GOMICRO}" > /opt/gomicro/etc/pkgin/repositories.conf && \
    /opt/gomicro/sbin/pkg_admin rebuild && \
    rm -rf /var/gomicro/db/pkgin && \
    /opt/gomicro/bin/pkgin -y up && \
    /opt/gomicro/bin/pkgin -yV in \
            mustache \
            narc \
            openssh \
            shon \
            siphon \
        && \
    rm -rf \
      /var/gomicro/db/pkgin \
      /opt/gomicro/share/{doc,ri,examples} \
      /opt/gomicro/man

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

# add gomicro binaries on path
ENV PATH /data/sbin:/data/bin:/opt/gomicro/sbin:/opt/gomicro/bin:$PATH

# Add gomicro user
RUN mkdir -p /data/var/home && \
    groupadd gomicro && \
    useradd -m -s '/bin/bash' -p `openssl passwd -1 gomicro` -g gomicro -d /data/var/home/gomicro gomicro && \
    passwd -u gomicro

# Copy files
COPY files/base/. /

# Own all gomicro files
RUN chown -R gomicro:gomicro /data

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
