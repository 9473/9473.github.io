For build:

```
python build.py build 
```

For local review:

```
python build.py preview
```

Then, modify and publish

```
git add -A
git commit -m "trigger deploy"
git push
```

Finished.


-----

Notes:

1. arxiv 的 bib 会编译失败好像是因为不存在 doi
2. 