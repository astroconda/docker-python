FROM centos:6.9
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

RUN yum install -y epel-release \
    && yum clean all

RUN yum install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    git \
    glibc \
    libuuid-devel \
    make \
    perl \
    pkgconfig \
    expat-devel \
    bzip2-devel \
    gdbm-devel \
    libffi-devel \
    ncurses-devel \
    openssl-devel \
    readline-devel \
    sqlite-devel \
    sudo \
    tcl-devel \
    tk-devel \
    which \
    xz-devel \
    zlib-devel \
    && yum clean all

ENV TOOLCHAIN="/opt/toolchain"
ENV TOOLCHAIN_BIN="${TOOLCHAIN}/bin"
ENV TOOLCHAIN_LIB="${TOOLCHAIN}/lib"
ENV TOOLCHAIN_DATA="${TOOLCHAIN}/share"
ENV TOOLCHAIN_SYSCONF="${TOOLCHAIN}/etc"
ENV TOOLCHAIN_MAN="${TOOLCHAIN_DATA}/man"
ENV TOOLCHAIN_PKGCONFIG="${TOOLCHAIN_LIB}/pkgconfig"
ENV TOOLCHAIN_BUILD="/opt/buildroot"

ARG PYTHON_VERSION=${PYTHON_VERSION:-3.7.1}
ARG USER_ACCT=${USER_ACCT:-developer}
ARG USER_HOME=/home/${USER_ACCT}

RUN groupadd ${USER_ACCT} \
    && useradd -g ${USER_ACCT} -m -d ${USER_HOME} -s /bin/bash ${USER_ACCT} \
    && echo "${USER_ACCT}:${USER_ACCT}" | chpasswd \
    && echo "${USER_ACCT} ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers

RUN echo export PATH="${TOOLCHAIN_BIN}:\${PATH}" > /etc/profile.d/toolchain.sh \
    && echo export MANPATH="${TOOLCHAIN_MAN}:\${MANPATH}" >> /etc/profile.d/toolchain.sh \
    && echo export PKG_CONFIG_PATH="${TOOLCHAIN_PKGCONFIG}:\${PKG_CONFIG_PATH}" >> /etc/profile.d/toolchain.sh

WORKDIR "${TOOLCHAIN_BUILD}"
COPY scripts/ ${TOOLCHAIN_BUILD}/bin
COPY etc/ ${TOOLCHAIN_BUILD}/etc

RUN mkdir -p "${TOOLCHAIN}" \
    && chown -R ${USER_ACCT}: \
        ${TOOLCHAIN} \
        ${TOOLCHAIN_BUILD}

USER "${USER_ACCT}"

RUN bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

WORKDIR "${USER_HOME}"

CMD ["/bin/bash", "-l"]
