#!/bin/bash

set -eo pipefail

# hugo build to public dir
# if main branch
#   push public dir to gh-pages 
# else
#   create heroku review app via api with circle branch

static_branch=$CIRCLE_BRANCH-static-ci

cd ~/hugo
HUGO_ENV=production hugo -v

git fetch && git checkout -b origin/$static_branch $static_branch || git checkout -b $static_branch
mkdir -p ../tmp/.circleci && cp -a .circleci/. ../tmp/.circleci/. # copy circleci config to tmp dir
git rm -rf . # remove everything
mv public/* . # move hugo generated files into root of branch dir
cp -a ../tmp/.circleci . # copy circleci config back to prevent triggering build on ignored branches
git push origin $static_branch

curl -n -X POST https://api.heroku.com/review-apps \
  -d '{"branch":"static","pipeline":"'$HEROKU_PIPELINE_ID'","source_blob": { "url":"https://api.github.com/repos/sfdigitalservices/sfdigitalservices/tarball/'$static_branch'","version":"null"}}' \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3" \
  -H "Authorization: Bearer $HEROKU_AUTH_TOKEN"
