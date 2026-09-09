#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "layout.typ": full-width, margin-note
#import "links.typ": template-links
#import "quotes.typ": template-quotes
#import "metadata.typ": metadata

/// Tufted 博客模板的主包装函数。
#let tufted-web(
  header-links: (:),

  // Meta data
  title: "",
  author: none,
  description: "",
  lang: "zh",
  date: none,
  website-title: "",
  website-url: none,

  // For SEO
  image-path: none,

  // For RSS
  feed-dir: (),

  // Custom header and footer
  header-elements: (),
  footer-elements: (),

  // Custom CSS and JS Scripts
  css: (),
  js-scripts: (),

  content,
) = {
  // Apply styling
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures
  show: template-links
  show: template-quotes

  set text(lang: lang)

  html.html(
    lang: lang,
    {
      // Head
      html.head({
        metadata(
          title: title,
          author: author,
          description: description,
          lang: lang,
          date: date,
          website-title: website-title,
          website-url: website-url,
          image-path: image-path,
          feed-dir: feed-dir,
        )

        let base-css = (
          "/assets/openai.css?v=20260701-math-2",
        )
        for (css-src) in (base-css + css).dedup() {
          html.link(rel: "stylesheet", href: css-src)
        }

        let base-js = (
          "/assets/code-blocks.js",
          "/assets/format-headings.js",
          "/assets/marginnote-toggle.js",
        )
        for (js-src) in (base-js + js-scripts).dedup() {
          html.script(src: js-src)
        }
      })

      // Body
      html.body({
        html.header(
          class: "site-header",
          {
            for (i, element) in header-elements.enumerate() {
              element
              if i < header-elements.len() - 1 {
                html.br()
              }
            }
          },
        )

        html.header(
          class: "site-header",
          if header-links != none and header-links.len() > 0 {
            html.nav(
              class: "site-nav",
              for (href, title) in header-links {
                html.a(href: href, title)
              },
            )
          }
        )

        html.article(
          html.section(content),
        )

        html.footer({
          for (i, element) in footer-elements.enumerate() {
            element
            if i < footer-elements.len() - 1 {
              html.br()
            }
          }
        })
      })
    },
  )
}
