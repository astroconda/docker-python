#!/bin/bash
HUB=${3:-astroconda}
PROJECT=${HUB}/datb-tc-python
PROJECT_VERSION="${1}"
BASE_IMG_VERSION=${2:-latest}
TAGS=()
EXTRA=()
SNAPSHOT=${SNAPSHOT:-}

if [[ -n ${SNAPSHOT} ]]; then
    EXTRA+=( "--no-cache" )
    EXTRA+=( "--pull" )
fi

if [[ -z ${PROJECT_VERSION} ]]; then
    echo "Python version required [e.g. 3.7.1]"
    exit 1
fi

read \
    PROJECT_VERSION_MAJOR \
    PROJECT_VERSION_MINOR \
    PROJECT_VERSION_PATCH <<< ${PROJECT_VERSION//\./ }

case "${HUB}" in
    *amazonaws\.com)
        if ! type -p aws; then
            echo "awscli client not installed"
            exit 1
        fi
        REGION="$(awk -F'.' '{print $(NF-2)}' <<< ${HUB})"
        $(aws ecr get-login --no-include-email --region ${REGION})
        unset REGION
        ;;
    *)
        # Assume default index
        docker login
        ;;
esac
set -x

TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION}" )
is_tag_latest=$([[ -f LATEST ]] && [[ $(<LATEST) == ${PROJECT_VERSION} ]] && echo yes)
if [[ -n ${is_tag_latest} ]]; then
    TAGS+=( "-t ${PROJECT}:latest" )
    TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION_MAJOR}" )
    TAGS+=( "-t ${PROJECT}:${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}" )
fi

docker build \
    ${EXTRA[@]} \
    ${TAGS[@]} \
    --build-arg HUB="${HUB}" \
    --build-arg PYTHON_VERSION="${PROJECT_VERSION}" \
    --build-arg BASE_VERSION="${BASE_IMG_VERSION}" \
    .

rv=$?
if (( rv > 0 )); then
    echo "Failed... Image not published"
    exit ${rv}
fi


max_retry=4
retry=0
set +e
for tag in "${TAGS[@]}"
do
    # strip argument prefix
    tag=${tag#"-t"}
    tag=${tag#" "}

    while (( retry != max_retry ))
    do
        echo "Push attempt #$(( retry + 1 ))"
        docker push "${tag}"
        rv=$?
        if [[ ${rv} == 0 ]]; then
            break
        fi
        (( retry++ ))
    done
done

exit ${rv}
