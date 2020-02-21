[![CircleCI](https://circleci.com/gh/SFDigitalServices/sfdigitalservices.svg?style=svg)](https://circleci.com/gh/SFDigitalServices/sfdigitalservices)

# Build locally
## Get Hugo
### via homebrew:
```
$ brew install hugo
```
### or binary install:
Pick the appropriate binary from here:
[https://github.com/gohugoio/hugo/releases](https://github.com/gohugoio/hugo/releases)

## Generate site

```
$ hugo
```

## Serve it up
```
$ hugo server -w
```
Hit [http://localhost:1313](http://localhost:1313) to verify that the site was generated correctly

## Create a new page
Creating a new page can be as simple as creating a file (xyz.html) in the `/content` folder.  Or via the command line (at the root directory of this repo):

```
$ hugo new xyz.html
```
These new pages will follow the layout template in `/themes/digitalservices/_default/single.html`

# How to add team members to website

* When a new person joins the team, get their profile photo in .jpg or .png formats
* Add their profile photo to the `themes/digitalservices/static/assets` folder, name it like this: `firstname.jpg` or `firstname.png`
* Follow the instructions above to build the site locally and preview changes.
* Edit the `content/ourteam.html` file, add team members in `<div id="staff">` by adding a new `<li class="col-xs-12 col-md-6 col-lg-4">` block
* Make sure that their name, job title and photo are correct
* Submit a PR 
* Once your PR has been approved by a reviewer, who will also send you a preview of your changes (in the form of a Pantheon link), check your preview then merge your PR. If you are not happy with the changes, commit to the same branch, which will generate another Pantheon preview.
* Merge your PR
* Reach out to someone with server access (currently, that would be @skinnylatte, @aekong and @henryjiang-sfgov) to deploy with the following commands

```
 cd /var/www/html/digitalservices
$ cd public
$ sudo git fetch --all
$ sudo git reset --hard origin/gh-pages
```

## Notes
* Never ever edit files in /public directly (this is hugo generated)
* This repo is a very basic site, with very few (what hugo calls) content types
* Refer to Hugo documentation at [https://gohugo.io/documentation/](https://gohugo.io/documentation/)
