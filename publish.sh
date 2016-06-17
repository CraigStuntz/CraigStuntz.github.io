#!/bin/bash
git checkout master
git merge develop -X theirs -m "Merge branch develop"
cp -a _site/. .
rm posts/*.markdown
git add .
