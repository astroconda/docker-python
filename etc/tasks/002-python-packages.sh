#!/bin/bash
set -x

# Uses GLOBAL environment variable: PYTHON_VERSION defined by `docker build` argument
prefix="${TOOLCHAIN}"
sysconfdir="${TOOLCHAIN_BUILD}/etc"
reqdir=${sysconfdir}/pip

export PATH="${prefix}/bin:${PATH}"
export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
export CFLAGS="-I${prefix}/include"
export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"

function pre()
{
    if [[ ! -d ${reqdir} ]]; then
        # Nothing there, but maybe that's on purpose.
        exit 0
    fi
}

function build()
{
    pre
    # Iterate over pip requirement files
    for req in ${reqdir}/*
    do
        pip install --upgrade --progress-bar=off -r "${req}"
        retval=$?
        if [[ ${retval} != 0 ]]; then
            echo "BUILD FAILED: ${req}"
            exit ${retval}
        fi
    done
    post
}

function post()
{
    rm -rf ~/.cache/pip
    [[ -d src ]] && rm -rf src || true
    [[ -f gmon.out ]] && rm -rf gmon.out || true
}

build
