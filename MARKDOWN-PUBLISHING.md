# 用 Markdown 发布 Blog 和 Open Notes

需要 Typst 0.15.0 和 Python 3.10+（推荐 `uv`）。GitHub Actions 已固定 Typst 版本。

新建 `content/Blog/文章目录/index.md`，或 `content/Docs/笔记目录/index.md`：

```markdown
---
title: "文章标题"
date: "2026-09-07"
lang: zh
description: "一句话简介"
tags: [QMC, Notes]
---

# 文章标题

正文支持 **Markdown**、行内公式 $x^2$ 和独立公式：

$$
R_1 = \operatorname{Tr}(\sqrt{\rho} O \sqrt{\rho} O)
$$

![图片说明](imgs/figure.png)
```

将图片放在该文章目录的 `imgs/` 下。正文直接由 cmarker + mitex 在 Typst 内渲染，不生成中间文章 `.typ` 文件，沿用网站现有模板。标题字段必填，其余字段可选；日期使用带引号的 `YYYY-MM-DD` 字符串。页面正文标题写在 Markdown 的 `#` 标题里。

构建时文章自动出现在 Blogs / Open Notes 的索引中，按日期倒序排列。Blog 按 YAML 的 `lang` 分区：`en` 显示在主区域 Posts；`zh`、`zh-CN` 等中文语言显示在右侧 Journal，窄屏时 Journal 位于 Posts 后面。省略 `lang` 默认中文。Open Notes 仍使用 Notes 列表。列表收录所有已发布的 Markdown 页面，没有时间窗口或篇数限制，旧文章不会自动移出。已有 Typst 页面和手动链接保留；首页和 CV 不支持 Markdown 页面入口。同一目录不能同时存在 `index.md` 和 `index.typ`。

只有名为 `index.md` 的文件会成为页面，其他 `.md` 文件仍按原框架作为静态资源复制。未准备发布的内容放在 `_drafts/` 等以下划线开头的目录，整个目录不会编译或复制；不支持 `draft: true`。

参考文献：将 `.bib` 放在文章目录，在 YAML 中添加 `bibliography: references.bib`，正文用 `[@文献键]` 引用，末尾自动生成 References。

LaTeX 数学支持以 mitex 为准，不等同于完整 LaTeX 宏包环境。支持 `\Tr` 作为 `\operatorname{Tr}` 的别名。多行公式不要把 `=` 单独写一行，以免被 CommonMark 当成标题下划线；将等号放在前一行末尾即可。

需要高级组件时可写 `<!--raw-typst #tufted.margin-note[旁注] -->`。

```sh
uv run build.py build -f
uv run build.py preview
```

增量构建 `uv run build.py html` 会追踪 Markdown 和文章子目录的图片变化。删除、移动文章后使用完整构建 `build -f` 清除旧输出；GitHub 部署始终完整构建。

检查：`uv run --python 3.12 python -m unittest discover -s tests`。
