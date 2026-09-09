#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "Technical posts and personal journals",
  css: ("/Blog/index-layout.css?v=20260909",),
)

= 博客 / Blog

#html.div(class: "blog-layout", {
  html.div(class: "blog-posts", {
    heading(level: 2)[Posts]
    html.div(id: "blog-posts")
  })
  html.aside(class: "blog-journals", {
    heading(level: 2)[Journal]
    heading(level: 3)[2026]
    [
    - #link("2026-06-15-yanyun1/")[燕云十六声：碧波垂钓与风雪岱山]
    - #link("2026-04-20-zhuazhu-xiangbiao/")[读项飙访谈有感]
    ]
    html.div(id: "blog-journals")
  })
})
