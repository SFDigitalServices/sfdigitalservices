#!/bin/bash

set -eo pipefail

# hugo build to public dir
# if main branch
#   push public dir to gh-pages 
# else
#   create heroku review app via api with circle branch

static_branch=$CIRCLE_BRANCH-static

cd ~/hugo
HUGO_ENV=production hugo -v

git checkout -b $static_branch
git rm -rf . # remove everything
mv public/* . # move hugo generated files into root of branch dir
git push origin $static_branch

curl -n -X POST https://api.heroku.com/review-apps \
  -d '{"branch":"static","pipeline":"'$HEROKU_PIPELINE_ID'","source_blob": { "url":"https://api.github.com/repos/sfdigitalservices/sfdigitalservices/tarball/'$static_branch'","version":"null"}}' \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3" \
  -H "Authorization: Bearer $HEROKU_AUTH_TOKEN"
