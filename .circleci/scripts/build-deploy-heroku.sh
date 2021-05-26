#!/bin/bash

set -eo pipefail

static_branch=$CIRCLE_BRANCH-static-ci
pr_number=${CIRCLE_PULL_REQUEST##*/}

cd ~/hugo
HUGO_ENV=production hugo -v

git config --global user.email $GH_EMAIL
git config --global user.name $GH_NAME

git fetch && git checkout -b origin/$static_branch $static_branch || git checkout -b $static_branch
mkdir -p ../tmp/.circleci && cp -a .circleci/. ../tmp/.circleci/. # copy circleci config to tmp dir
git rm -rf . # remove everything
mv public/* . # move hugo generated files into root of branch dir
cp -a ../tmp/.circleci . # copy circleci config back to prevent triggering build on ignored branches
git add -A

if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
  git commit -m "build $CIRCLE_SHA1 to gh-pages"
  git push -f origin gh-pages
else
  # make this branch deployable on heroku
  echo "{}" > composer.json
  echo "<?php include_once('index.html'); ?>" > index.php

  git add -A
  git commit -m "review app static build for $CIRCLE_BRANCH $CIRCLE_SHA1"
  git push -f origin $static_branch

  # create review app on heroku
  curl -X POST https://api.heroku.com/review-apps \
    -d '{"branch":"'$static_branch'","pr_number":"'$pr_number'","pipeline":"'$HEROKU_PIPELINE_ID'","source_blob": { "url":"https://api.github.com/repos/sfdigitalservices/sfdigitalservices/tarball/'$static_branch'","version":"null"}}' \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.heroku+json; version=3" \
    -H "Authorization: Bearer $HEROKU_AUTH_TOKEN"

  sleep 30s # wait for review app to grab the source blob

  # delete static-ci branch from github
  curl -X DELETE https://api.github.com/repos/SFDigitalServices/sfdigitalservices/git/refs/heads/$static_branch \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: Bearer $GH_ACCESS_TOKEN"
fi
