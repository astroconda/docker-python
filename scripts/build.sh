#!/bin/bash -e

taskdir=${TOOLCHAIN_BUILD}/etc/tasks
export _maxjobs=$(getconf _NPROCESSORS_ONLN)

if [[ ! -d ${taskdir} ]]; then
    echo "No tasks. ${taskdir} does not exist."
    exit 1
fi

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
