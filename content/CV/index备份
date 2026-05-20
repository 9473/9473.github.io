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
  let items = bib.values()

  let month-num(month) = {
    let m = if type(month) == str { month } else { "13" }
    if m == "jan" or m == "Jan" or m == "1" { 1 } else if m == "feb" or m == "Feb" or m == "2" { 2 }
    else if m == "mar" or m == "Mar" or m == "3" { 3 } else if m == "apr" or m == "Apr" or m == "4" { 4 }
    else if m == "may" or m == "May" or m == "5" { 5 } else if m == "jun" or m == "Jun" or m == "6" { 6 }
    else if m == "jul" or m == "Jul" or m == "7" { 7 } else if m == "aug" or m == "Aug" or m == "8" { 8 }
    else if m == "sep" or m == "Sep" or m == "9" { 9 } else if m == "oct" or m == "Oct" or m == "10" { 10 }
    else if m == "nov" or m == "Nov" or m == "11" { 11 } else if m == "dec" or m == "Dec" or m == "12" { 12 }
    else { 13 }
  }

  let sorted = items.sorted(by: (a, b) => {
    let ya = int(a.fields.at("year", default: "0"))
    let yb = int(b.fields.at("year", default: "0"))
    if ya > yb { true } else if ya < yb { false } else {
      let ma = month-num(a.fields.at("month", default: "13"))
      let mb = month-num(b.fields.at("month", default: "13"))
      ma >= mb
    }
  })

  let items-content = ()

  for item in sorted {
    let data = item.fields
    let authors = data.author.split(" and ").map(s => s.trim())
    let bolded = authors.map(a => {
      if "Zhiyan Wang" in a { strong[#a] } else { a }
    }).join(", ")
    items-content.push(
      [#bolded, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]]
    )
  }

  enum(..items-content)
}