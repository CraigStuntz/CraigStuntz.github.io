#!/bin/bash
set -ex

git push
stack exec blog build
git checkout master
cp -a _site/. .
rm -f posts/*.markdown
rm -f *.markdown
git add .
git commit -m "Publish"
git push
