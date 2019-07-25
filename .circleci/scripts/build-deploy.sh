#!/bin/bash

set -eo pipefail

cd ..

git config --global user.email $GH_EMAIL
git config --global user.name $GH_NAME

git clone $CIRCLE_REPOSITORY_URL $CIRCLE_BRANCH
cd $CIRCLE_BRANCH
git checkout $CIRCLE_BRANCH || git checkout --orphan $CIRCLE_BRANCH
HUGO_ENV=production hugo -v
git rm -rf .
mv public/* .
git add -A
git commit -m "build ${CIRCLE_BRANCH} to pantheon: ${CIRCLE_SHA1}" --allow-empty

git remote add pantheon $PANTHEON_REMOTE

terminus -n auth:login --machine-token="$TERMINUS_MACHINE_TOKEN"
terminus multidev:create $PANTHEON_SITENAME.dev ci-$CIRCLE_BUILD_NUM

ssh-add -D
ssh-add ~/.ssh/id_rsa_$PANTHEON_SSH_FINGERPRINT
ssh-keyscan -H -p $PANTHEON_CODESERVER_PORT $PANTHEON_CODESERVER >> ~/.ssh/known_hosts

git push -f pantheon $CIRCLE_BRANCH:ci-$CIRCLE_BUILD_NUM

if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
  # merge multidev to master
  terminus multidev:merge-to-dev $PANTHEON_SITENAME.ci-$CIRCLE_BUILD_NUM
  terminus multidev:delete --delete-branch $PANTHEON_SITENAME.ci-$CIRCLE_BUILD_NUM
fi

terminus auth:logout