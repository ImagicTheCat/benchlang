#!/usr/bin/env sh
git branch -D gh-pages
git checkout --orphan gh-pages
git rm . -r --cached

# gen site
luajit gen_site.lua

# publish
git add site
git mv site/* .
git commit -a -m "Publish."
echo "publish: git push -u origin gh-pages --force"
