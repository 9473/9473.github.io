#import "../index.typ": template, tufted
#show: template.with(
  title: "Edward R. Tufte",
  description: "CV of Edward R. Tufte",
  lang: "en"
)
#import "@preview/citegeist:0.2.0": load-bibliography

= Zhiyan Wang

#tufted.margin-note[
  Numerical physics, Ph.D. Student \
  Email: #link("wangzhiyan@westlake.edu.cn")
]

== Papers

#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}



== Experience

- PhD in Westlake University (2024).
- BS in Lanzhou University (2019).