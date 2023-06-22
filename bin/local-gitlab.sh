#!/bin/bash

# Assumes you do
# docker login -u $CI_REGISTRY_USER -p $CI_BUILD_TOKEN $CI_REGISTRY
# in your before_script

die() {
  >&2 echo $*
  exit 1
}

[ jq 2> /dev/null ] || die "Please apt install jq"
[ yq 2>/dev/null ] || die "Please pip3 install yq"
if [[ "$OSTYPE" == "darwin"* ]]; then
    [ realpath 2>/dev/null ] || die "Please brew install coreutils!"
fi
[ -f ~/.docker/config.json ] || die "Please get a token from web iface and 'docker login'"
[ -f .gitlab-ci.yml ] || die "Please execute from a directory with a .gitlab-ci.yml"
[ -d .git ] || die "Please execute this from a directory that is in git, has a origin"

set -ex

if [ $# -eq 0 ]
then
  # run all stages
  STAGES=$(cat .gitlab-ci.yml | yq e .stages | sed -e 's?- ??g' | tr '\n' ' ' )
else
  STAGES="$@"
fi

STEPS=$(yq -rc e 'keys' .gitlab-ci.yml | jq -r .[])
echo $STEPS
# AUTH=$(jq -r '.auths["...myregistry..."].auth' < ~/.docker/config.json  | base64 -d)
#IFS=:
# set -- $AUTH

# echo "docker login -u $1 -p $2 ...myregistry..."

CI_PROJECT_PATH=$(git remote get-url origin | sed -e 's?.*:??' -e 's?\.git??g')
CI_PROJECT_NAME=$(basename $(realpath .))
CI_PROJECT_NAMESPACE=$(dirname $CI_PROJECT_PATH)
CI_PROJECT_DIR=/$CI_PROJECT_PATH

COMMIT_HASH=$(git rev-parse HEAD)
unset IFS

mkdir -p .gitlab-ci.cache .gitlab-ci.cache/images
chown -R $(id -u):$(id -g) .gitlab-ci.cache
echo "Will run <<$STAGES>>"
for stage in $STAGES
do
  for step in $STEPS
  do
    stage_check=$(yq -rc e ".$step.stage==\"$stage\"" .gitlab-ci.yml )

    if [ "$stage_check" != "true" ]; then
      continue
    fi

    echo "Execute $stage - $step"
    gitlab-runner \
      exec docker --docker-privileged \
      --cache-dir=$CI_PROJECT_DIR/.cache \
      --builds-dir=$CI_PROJECT_DIR \
      --docker-volumes $PWD/.gitlab-ci.cache:$CI_PROJECT_DIR/.cache \
      --env CI_PROJECT_DIR=$CI_PROJECT_DIR \
      --env CI_PROJECT_NAMESPACE=$CI_PROJECT_NAMESPACE \
      --env CI_PROJECT_NAME=$CI_PROJECT_NAME \
      --env CI_COMMIT_REF_NAME=$COMMIT_HASH \
      --env CI_PROJECT_PATH=$CI_PROJECT_PATH \
      --env CI_COMMIT_SHA=$COMMIT_HASH \
      --env CI_REGISTRY_USER=$1 \
      --env CI_BUILD_TOKEN=$2 \
      "$step"
   done
done
res=$?
chown -R $(id -u):$(id -g) .gitlab-ci.cache
exit $res