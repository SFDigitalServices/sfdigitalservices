#!/bin/bash

set -eo pipefail

export PATH=$PATH:/home/circleci/hugo/vendor/bin

cd ..

git config --global user.email $GH_EMAIL
git config --global user.name $GH_NAME

git clone $CIRCLE_REPOSITORY_URL $CIRCLE_BRANCH

ssh-add -D
ssh-add ~/.ssh/id_rsa_$PANTHEON_SSH_FINGERPRINT
ssh-keyscan -H -p $PANTHEON_CODESERVER_PORT $PANTHEON_CODESERVER >> ~/.ssh/known_hosts

cd $CIRCLE_BRANCH
git checkout $CIRCLE_BRANCH || git checkout --orphan $CIRCLE_BRANCH
HUGO_ENV=production hugo -v
mkdir -p ../tmp/.circleci && cp -a .circleci/. ../tmp/.circleci/. # copy circleci config to tmp dir
git rm -rf . # remove everything
mv public/* . # move hugo generated files into root of branch dir
cp -a ../tmp/.circleci . # copy circleci config back to prevent triggering build on gh-pages

git remote add pantheon $PANTHEON_REMOTE
git add -A

terminus -n auth:login --machine-token="$TERMINUS_MACHINE_TOKEN"
git push -f pantheon $CIRCLE_BRANCH:master

if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
  git commit -m "build ${CIRCLE_BRANCH} ${CIRCLE_SHA1}" --allow-empty
  git push -f origin $CIRCLE_BRANCH:gh-pages
fi

terminus auth:logout
