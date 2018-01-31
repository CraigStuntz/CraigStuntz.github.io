#!/bin/bash
set -ex

stack exec blog build
git checkout master
git fetch
git reset --hard origin/master
cp -a _site/. .
rm -f posts/*.markdown
rm -f *.markdown
git add .
git commit -m "Publish"
git push --set-upstream origin master
