#!/bin/bash
PROJECT=astroconda/python
PYTHON_VERSION="${1}"
if [[ -z ${PYTHON_VERSION} ]]; then
    echo "Need a fully qualified Python version to build. [e.g. 3.7.1]"
    exit 1
fi

BASE_VERSION="${2}"
if [[ -z ${BASE_VERSION} ]]; then
    BASE_VERSION="latest"
fi

is_tag_latest=$([[ -f LATEST ]] && [[ $(<LATEST) == ${PYTHON_VERSION} ]] && echo yes)
if [[ -n ${is_tag_latest} ]]; then
    tag_latest="-t ${PROJECT}:latest"
fi


docker build -t ${PROJECT}:${PYTHON_VERSION} \
    ${tag_latest} \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build_arg BASE_VERSION=${BASE_VERSION} \
    .
