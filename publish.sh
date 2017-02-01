#!/bin/bash
stack exec blog build
git checkout master
git merge develop -X theirs -m "Merge branch develop"
git add .
git commit -m "Publish"
cp -a _site/. .
rm -f posts/*.markdown
git add .
