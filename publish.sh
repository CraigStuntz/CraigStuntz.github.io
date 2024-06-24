#!/bin/bash
set -ex

stack build
stack exec blog build
git checkout master
git fetch
git reset --hard origin/master
git restore --source develop .gitignore
cp -a _site/. .
rm -f drafts/*.markdown
rm -f posts/*.markdown
rm -f *.markdown
git add .
git commit -m "Publish"
git push --set-upstream origin master
