#!/bin/bash

set -eo pipefail

cd ..

git config --global user.email $GH_EMAIL
git config --global user.name $GH_NAME

git clone $CIRCLE_REPOSITORY_URL $CIRCLE_BRANCH
cd $CIRCLE_BRANCH
git checkout $CIRCLE_BRANCH || git checkout --orphan $CIRCLE_BRANCH
hugo
git rm -rf .
mv public/* .
git add -A
git commit -m "build ${CIRCLE_BRANCH} to pantheon: ${CIRCLE_SHA1}" --allow-empty

terminus -n auth:login --machine-token="$TERMINUS_MACHINE_TOKEN"
terminus multidev:create $PANTHEON_SITENAME.dev ci-$CIRCLE_BUILD_NUM

git push -f pantheon test-branch:ci-$CIRCLE_BUILD_NUM