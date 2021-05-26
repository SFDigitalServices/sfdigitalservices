#!/bin/bash

set -eo pipefail

static_branch=$CIRCLE_BRANCH-static-ci

cd ~/hugo

echo "Run hugo to build static site"
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
  # main branch, checkout gh-pages, merge with static, push
  git checkout -b gh-pages origin/gh-pages
  git merge $static_branch -m "build $CIRCLE_SHA1 to gh-pages"
  git push origin gh-pages
else
  pr_number=$(expr ${CIRCLE_PULL_REQUEST##*/} + 0)
  
  # make this branch deployable on heroku
  echo "{}" > composer.json
  echo "<?php include_once('index.html'); ?>" > index.php

  # push the static site branch to github (for heroku review app api)
  git add -A
  git commit -m "review app static build for $CIRCLE_BRANCH $CIRCLE_SHA1"
  git push -f origin $static_branch

  # TODO:
  # currently will not create review app if it already exists
  # list review apps
  # loop through and search for static_branch name
  # if it exists, get review app id and delete review app before creating

  # create review app on heroku
  curl -X POST https://api.heroku.com/review-apps \
    -d '{"branch":"'$static_branch'","pr_number":'$pr_number',"pipeline":"'$HEROKU_PIPELINE_ID'","source_blob": { "url":"https://api.github.com/repos/sfdigitalservices/sfdigitalservices/tarball/'$static_branch'","version":"'$CIRCLE_SHA1'"}}' \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.heroku+json; version=3" \
    -H "Authorization: Bearer $HEROKU_AUTH_TOKEN"

  sleep 30s # wait for review app to grab the source blob

  # delete static-ci branch from github
  curl -X DELETE https://api.github.com/repos/SFDigitalServices/sfdigitalservices/git/refs/heads/$static_branch \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: Bearer $GH_ACCESS_TOKEN"
fi
