#!/bin/bash
stack exec blog build
git checkout master
git merge develop -X theirs -m "Merge branch develop"
cp -a _site/. .
rm -f posts/*.markdown
rm -f *.markdown
git add .
git commit -m "Publish"
