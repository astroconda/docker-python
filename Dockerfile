ARG BASE_VERSION=${BASE_VERSION:latest-}
FROM astroconda/base:${BASE_VERSION}
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

ARG PYTHON_VERSION=${PYTHON_VERSION:-3.7.1}

USER root

RUN yum install -y epel-release \
    && yum install -y \
        bzip2-devel \
        expat-devel \
        gdbm-devel \
        git \
        libffi-devel \
        libuuid-devel \
        ncurses-devel \
        openssl-devel \
        readline-devel \
        sqlite-devel \
        tcl-devel \
        tk-devel \
        xz-devel \
        zlib-devel \
    && yum clean all

WORKDIR "${TOOLCHAIN_BUILD}"

COPY scripts/ ${TOOLCHAIN_BUILD}/bin
COPY etc/ ${TOOLCHAIN_BUILD}/etc
RUN chown -R ${USER_ACCT}: "${TOOLCHAIN_BUILD}"

USER "${USER_ACCT}"
RUN bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

WORKDIR "${USER_HOME}"

CMD ["/bin/bash", "-l"]
