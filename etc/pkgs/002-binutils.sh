#!/bin/bash
name=binutils
version=2.31.1
url=https://ftp.gnu.org/gnu/binutils/${name}-${version}.tar.gz

curl -LO ${url}
tar xf ${name}-${version}.tar.gz

mkdir -p binutils
pushd binutils
    ../${name}-${version}/configure \
        --prefix=${TOOLCHAIN} \
        --with-sysroot=${TOOLCHAIN}
    make -j${_maxjobs}
    make install
popd
