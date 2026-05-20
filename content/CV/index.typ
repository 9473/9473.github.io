#import "../../config.typ": template
#show: template
#import "@preview/citegeist:0.2.0": load-bibliography

= Zhiyan Wang
#v(0.5em)

== Selected Research

#v(1em)
#html.div(class: "research-cards", {
  html.a(
    href: "https://doi.org/10.1038/s41467-025-67324-0",
    class: "research-card",
    target: "_blank",
    rel: ("noopener", "noreferrer"),
    [
    #html.span(class: "research-eyebrow")[Method]
    #html.strong[BRA Method for General Measurement in QMC]
    #html.p[
      Developed a novel reweight-annealing process in Quantum Monte Carlo (QMC) to address generic measurements, overcoming the difficulties associated with off‑diagonal measurements in strongly correlated quantum many-body systems.
    ]
    #image("imgs/fig_keyn.png", width: 100%)
    ],
  )

  html.a(
    href: "https://arxiv.org/abs/2603.10948",
    class: "research-card",
    target: "_blank",
    rel: ("noopener", "noreferrer"),
    [
    #html.span(class: "research-eyebrow")[Framework]
    #html.strong[Generalized Reduced Density Matrix (GRDM)]
    #html.p[
      A novel unified framework that simultaneously accesses the imaginary-time dynamical reduced density matrix and the standard reduced density matrix in QMC, enabling large-scale measurements of generic entanglement and correlation observables in complex interacting systems.
    ]
    #image("imgs/GRDM.svg", width: 200%)
    ],
  )
})

#v(3.5em)
== Publications
#v(1em)

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

  let count = sorted.len()
  for (index, item) in sorted.enumerate() {
    let data = item.fields
    let authors = data.author.split(" and ").map(s => s.trim())
    
    let bolded = authors.map(a => {
      if "Zhiyan Wang" in a { html.span(class: "publication-me")[#a] } else { a }
    }).join(", ")
    
    html.div(class: "publication-item", [
      #html.span(class: "publication-index")[#(count - index).]
      #html.span(class: "publication-body")[
        #bolded,
        “#data.title,”
        #html.span(class: "publication-journal")[#data.journal],
        #data.year.
        #html.span(class: "publication-doi")[DOI: #link(data.url)[#data.doi]]
      ]
    ])
  }
}
