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

if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
  git commit -m "build ${CIRCLE_BRANCH} ${CIRCLE_SHA1}" --allow-empty
  git push -f pantheon $CIRCLE_BRANCH:master
  git push -f origin $CIRCLE_BRANCH:gh-pages
else
  git commit -m "build ${CIRCLE_BRANCH} to pantheon remote ci-${CIRCLE_BUILD_NUM}: ${CIRCLE_SHA1}" --allow-empty
  terminus -n auth:login --machine-token="$TERMINUS_MACHINE_TOKEN"

  # do some cleanup
  terminus multidev:list $PANTHEON_SITENAME --format=list --fields=name > multidevs.txt # capture multidevs to file
  MD_COUNT="$(< multidevs.txt wc -l)" # capture the multidev count (# lines in file from above)
  if [ $MD_COUNT -gt 5 ]; then
    echo "Removing older multidevs"
    # remove first 3 multidevs in file list
    head -3 multidevs.txt |
    while read multidev; do
      terminus multidev:delete  --delete-branch -y -- $PANTHEON_SITENAME.$multidev
    done
  else
    echo "No need to remove multidevs.  Count: $MD_COUNT"
  fi

  terminus multidev:create $PANTHEON_SITENAME.dev ci-$CIRCLE_BUILD_NUM
  git push -f pantheon $CIRCLE_BRANCH:ci-$CIRCLE_BUILD_NUM
  terminus auth:logout

  # comment on commit with review site
  GIT_COMMIT_SHA=$(git log --pretty=format:"%H" -n 1)
  COMMENT="review site: https://ci-${CIRCLE_BUILD_NUM}-sfdigitalservices.pantheonsite.io"
  OWNER="SFDigitalServices"
  REPO="sfdigitalservices"
  curl -u aekong:$GH_ACCESS_TOKEN -H "Content-Type: application/json" -d '{"body":"'"$COMMENT"'"}' -X POST https://api.github.com/repos/$OWNER/$REPO/commits/$GIT_COMMIT_SHA/comments

fi
