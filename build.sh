#!/bin/bash
PROJECT=astroconda/python
PYTHON_VERSION="${1}"
if [[ -z ${PYTHON_VERSION} ]]; then
    echo "Need a fully qualified Python version to build. [e.g. 3.7.1]"
    exit 1
fi

docker build -t ${PROJECT}:${PYTHON_VERSION} --build-arg PYTHON_VERSION=${PYTHON_VERSION} .
