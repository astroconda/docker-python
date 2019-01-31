#!/bin/bash -x

prefix="${TOOLCHAIN}"
taskdir=${TOOLCHAIN_BUILD}/etc/tasks

export _maxjobs=$(getconf _NPROCESSORS_ONLN)
export PATH="${prefix}/bin:${PATH}"
export CFLAGS="-I${prefix}/include"
export LDFLAGS="-L${prefix}/lib -Wl,-rpath=${prefix}/lib"
export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig"
export PREFIX="${prefix}"

if [[ ! -d ${taskdir} ]]; then
    echo "No tasks. ${taskdir} does not exist."
    exit 1
fi

printenv | sort

for task in ${taskdir}/*
do
    # Check for execution permission
    if [[ ! -x ${task} ]]; then
        echo "Skipping: ${task}"
        continue
    fi
    echo "Executing: ${task}"
    ${task}
    retval=$?
    if [[ ${retval} != 0 ]]; then
        echo "TASK FAILED: ${task}"
        exit ${retval}
    fi
done
