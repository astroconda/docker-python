#!/bin/bash -e

taskdir=${TOOLCHAIN_BUILD}/etc/tasks

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
done
