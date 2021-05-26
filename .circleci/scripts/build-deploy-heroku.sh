#!/bin/bash

set -eo pipefail

# hugo build to public dir
# if main branch
#   push public dir to gh-pages 
# else
#   create heroku review app via api with circle branch
