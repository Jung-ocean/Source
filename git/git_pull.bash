#!/bin/bash

repo='Source' # Remote repository name you want to pull
reponame='origin' # Bookmark for the remote repository
branch='main' # Branch name you want to pull

rm -rf ./.git

git init
git config --global user.name "Jung-ocean"
git config --global user.email j.jung@snu.ac.kr
git remote add ${reponame} https://github.com/Jung-ocean/${repo}.git
git remote set-url ${reponame} https://Jung-ocean@github.com/Jung-ocean/${repo}.git
git pull ${reponame} ${branch}
