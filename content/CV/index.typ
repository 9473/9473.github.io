#import "../index.typ": template, tufted
// #show: template.with(
//   title: "Edward R. Tufte",
//   description: "CV of Edward R. Tufte",
//   lang: "en"
// )
#show: template
#import "@preview/citegeist:0.2.0": load-bibliography

= Zhiyan Wang

#tufted.margin-note[
  Numerical physics, Ph.D. Student \
  Email: #link("wangzhiyan@westlake.edu.cn")
]


== Papers

#tufted.margin-note[
 *> BRA method for general measurement in QMC* \
]
#tufted.margin-note({
  image("imgs/fig_keyn.png")
})


#tufted.margin-note[
 *> Generalized Reduced Density Matrix (GRDM)* \
]
#tufted.margin-note({
  image("imgs/GRDM.svg")
  image("imgs/GRDM-update.svg")
})



#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}