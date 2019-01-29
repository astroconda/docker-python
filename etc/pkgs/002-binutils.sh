#!/bin/bash -x
name=binutils
version=2.31.1
url=https://ftp.gnu.org/gnu/binutils/${name}-${version}.tar.gz

curl -LO ${url}
tar xf ${name}-${version}.tar.gz

mkdir -p binutils
pushd binutils
    ../${name}-${version}/configure \
        --prefix=${TOOLCHAIN} \
        --target=x86_64-pc-linux-gnu \
        --enable-shared \
        --enable-lto \
        --enable-gold \
        --enable-ld=default \
        --enable-plugins \
        --enable-threads \
        --disable-static \
        --disable-multilib \
        --with-sysroot=/ \
        --with-tune=generic
    make -j4
    make install-strip
popd
