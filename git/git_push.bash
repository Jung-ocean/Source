#!/bin/bash

# You have to run git_pull.bash first
# Changing or adding files should be done after git_pull.bash
# Run git_push.bash after Changing or adding files 

reponame='origin' # Bookmark for the remote repository. This should be the same as the name determined by git_pull.bash
branch='main' # Branch name you want to push
file2upload=$1 # File or direcotry you want to push

git add ${file2upload}
time=`date "+%Y%m%d %H:%M:%S"`
git commit -m "${time}"
git checkout -b ${branch}

git push -u ${reponame} ${branch}
