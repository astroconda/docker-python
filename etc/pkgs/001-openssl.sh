#!/bin/bash
set -x

name="openssl"
version="1.1.0j"

tarball="${name}-${version}.tar.gz"
dest="${tarball%%.tar.gz}"
url="https://www.openssl.org/source/${tarball}"
prefix="${TOOLCHAIN}"


function pre()
{
    curl -LO "${url}"
    tar xf "${tarball}"
}


function get_system_cacert() {
  local paths=(
    /etc/ssl/cert.pem
    /etc/ssl/cacert.pem
    /etc/ssl/certs/cacert.pem
    /etc/ssl/certs/ca-bundle.crt
  )
  for bundle in "${paths[@]}"
  do
    if [[ -f ${bundle} ]]; then
        echo "${bundle}"
        break
    fi
  done
}


function build()
{
    pre
    pushd "${dest}"
        export PATH="${prefix}/bin:${PATH}"
        export LDFLAGS="-Wl,-rpath=${prefix}/lib"
        export KERNEL_BITS=64
        target="linux-x86_64"

        sed -i -e "s@./demoCA@${TOOLCHAIN}/ssl@" \
            apps/openssl.cnf \
            apps/CA.pl.in

        ./Configure \
            --prefix="${prefix}" \
            --openssldir="ssl" \
            --libdir="lib" \
            ${LDFLAGS} \
            ${target} \
            enable-ec_nistp_64_gcc_128 \
            zlib-dynamic \
            shared \
            no-ssl3-method
        make -j${_maxjobs}
        make install MANDIR="${prefix}/share/man" MANSUFFIX=ssl
    popd
    post
}

function post()
{
    bundle=$(get_system_cacert)
    install -D -m644 "${bundle}" "${prefix}/ssl/cert.pem"
    rm -rf "${prefix}/share/doc/openssl/html"
    rm -rf "${dest}"
    rm -rf "${tarball}"
    echo "All done."
}

# Main
build
