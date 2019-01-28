#!/bin/bash -e
set -x
name=gcc
version=8.2.0
url=http://mirrors-usa.go-parts.com/gcc/releases/${name}-${version}/${name}-${version}.tar.gz
src=${name}-${version}
bld=${src}_build

version_isl=0.20
url_isl=http://isl.gforge.inria.fr/isl-${version_isl}.tar.bz2

version_cloog=0.18.4
url_cloog="http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-${version_cloog}.tar.gz"

sudo yum install -y wget
sudo ln -sf ${TOOLCHAIN_LIB} ${TOOLCHAIN}/lib64

curl -LO ${url}
tar xf ${src}.tar.gz

mkdir -p ${bld}
pushd ${src}
    unset CFLAGS
    unset LDFLAGS

    # Disable fixincludes
    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in

    # Use /lib, not /lib64
    #sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64
    #sed -i 's/lib64/lib/g' gcc/config.gcc
    #sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" {libiberty,gcc}/configure

    # Download MPFR and friends
    ./contrib/download_prerequisites

    curl -LO ${url_isl}
    tar xf $(basename ${url_isl})
    ln -s isl-${version_isl} isl

    curl -LO ${url_cloog}
    tar xf $(basename ${url_cloog})
    ln -s cloog-${version_cloog} cloog
popd

pushd ${bld}
    # Beware: x86_64-only toolchain (multilib disabled)
    ../${src}/configure \
            --prefix=${TOOLCHAIN} \
            --libdir=${TOOLCHAIN_LIB} \
            --libexecdir=${TOOLCHAIN_LIB} \
            --disable-bootstrap \
            --disable-multilib \
            --disable-werror \
            --disable-libunwind-exceptions \
            --disable-libstdcxx-pch \
            --disable-libssp \
            --with-system-zlib \
            --with-isl \
            --with-linker-hash-style=gnu \
            --enable-languages=c,c++,fortran,lto,go \
            --enable-shared \
            --enable-threads=posix \
            --enable-libmpx \
            --enable-__cxa_atexit \
            --enable-clocale=gnu \
            --enable-gnu-unique-object \
            --enable-linker-build-id \
            --enable-lto \
            --enable-plugin \
            --enable-install-libiberty \
            --enable-gnu-indirect-function \
            --enable-default-pie \
            --enable-default-ssp \
            --enable-cet=auto \
            --enable-checking=release

    make -j${_maxjobs}
    make install-strip

    # Prevent ldconfig from picking up gdb python scripts
    autoload="${TOOLCHAIN_DATA}/gdb/auto-load${TOOLCHAIN_LIB}"
    mkdir -p "${autoload}"
    mv -v "${TOOLCHAIN_LIB}"/*gdb.py "${autoload}"

    # Enforce global linkage to toolchain
    /bin/echo "${TOOLCHAIN_LIB}" > gcc.conf
    sudo cp -a gcc.conf /etc/ld.so.conf.d
    sudo ldconfig
popd
