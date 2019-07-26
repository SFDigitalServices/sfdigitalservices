#!/bin/bash

set -eo pipefail

if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then

  cd ..

  git config --global user.email $GH_EMAIL
  git config --global user.name $GH_NAME

  git clone $CIRCLE_REPOSITORY_URL gh-pages

  cd gh-pages
  git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
  git rm -rf .
  cd ..
  
  cp -a hugo/public/. gh-pages/.
  
  mkdir -p gh-pages/.circleci && cp -a hugo/.circleci/. gh-pages/.circleci/. # copy circleci config to ignore triggering builds when pushing to gh-pages
  cd gh-pages

  git add -A
  git commit -m "Automated deploy to gh pages: ${CIRCLE_SHA1}" --allow-empty

  git push origin $TARGET_BRANCH

  # also push to pantheon remote
  git remote add pantheon $PANTHEON_REMOTE

  # use the right ssh key
  ssh-add -D
  ssh-add ~/.ssh/id_rsa_$PANTHEON_SSH_FINGERPRINT
  ssh-keyscan -H -p $PANTHEON_CODESERVER_PORT $PANTHEON_CODESERVER >> ~/.ssh/known_hosts
  git push -f pantheon gh-pages:master

fi