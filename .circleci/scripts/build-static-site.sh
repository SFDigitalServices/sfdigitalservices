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

# this is necessary because a separate manual deploy (which serves the gh-pages branch) happens on a city server
# because the domain digitalservices.sfgov.org is in use internally
if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
  # main branch, force push gh-pages
  git commit -m "build $CIRCLE_SHA1 to gh-pages"
  git push -f origin $static_branch:gh-pages
fi
