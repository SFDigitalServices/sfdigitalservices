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

## Notes
* Never ever edit files in /public directly (this is hugo generated)
* This repo is a very basic site, with very few (what hugo calls) content types
* Refer to Hugo documentation at [https://gohugo.io/documentation/](https://gohugo.io/documentation/)