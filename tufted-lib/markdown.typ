#import "../config.typ": template, tufted
#import "@preview/cmarker:0.1.10" as cmarker
#import "@preview/mitex:0.2.7": mitex

#let source = sys.inputs.at("markdown-source")
#let base = source.split("/").slice(0, -1).join("/")
#let local-path(path) = if path.starts-with("/") { path } else { base + "/" + path }
#let (meta, body) = cmarker.render-with-metadata(
  read(source),
  metadata-block: "frontmatter-yaml",
  math: (code, block: false) => mitex(code.replace("\\Tr", "\\operatorname{Tr}"), block: block),
  scope: (
    image: (path, ..args) => image(local-path(path), ..args),
    tufted: tufted,
  ),
)
#let code-dark = source.starts-with("/content/Blog/") and meta.at("theme", default: none) == "code-dark"
#set raw(theme: if code-dark { "code-dark.tmTheme" } else { auto })
#show: template.with(
  title: meta.at("title"),
  date: meta.at("date", default: none),
  description: meta.at("description", default: ""),
  lang: meta.at("lang", default: "zh"),
  blog-section: meta.at("section", default: none),
  blog-parent: meta.at("parent", default: none),
  css: if code-dark { ("/assets/code-dark.css?v=20261126",) } else { () },
)
#if "date" in meta { html.p(class: "post-date", str(meta.date)) }
#if "tags" in meta { html.p(class: "post-tags", meta.tags.join(" · ")) }
#body
#if "bibliography" in meta {
  bibliography(local-path(meta.bibliography), title: [References], style: "ieee")
}
