#import "../../config.typ": template
#show: template
#import "@preview/citegeist:0.2.0": load-bibliography

= Zhiyan Wang
#v(0.5em)

== Project

My work develops numerical ways of asking what is otherwise hard to ask in quantum many-body systems. I am interested not only in simulating models, but in expanding what can be measured, compared, and interpreted in Quantum Monte Carlo. Around this concern, my current work follows several connected lines: the general measurements problem, reduced density matrices, entanglement observables, and quantum criticality.

QMC is one of the main numerical methods that effectively simulate strongly interacting quantum models through the idea of stochastic sampling of partition functions, and it has significant advantages, especially in two dimensions. In condensed matter physics, this approach is commonly used to test, double-check, and even predict the results of theories and experiments.

=== Bipartite reweight-annealing algorithm of quantum Monte Carlo

A recurring difficulty in Quantum Monte Carlo is that the method often gives access to some observables much more naturally or diagonally than others. My work on the bipartite reweight-annealing method, and later on general measurements, grew out of this asymmetry: what can we learn if off-diagonal or nonstandard observables are no longer technically inaccessible? This line of work treats measurement itself as part of the physics problem. Instead of taking the accessible observables as given, I try to enlarge the measurable space of QMC.

As one of the contributors, I have been driving our group's effort to develop a method that enables large-scale computation of quantum entanglement entropy in QMC: the reweight-annealing method. Our project, #link("https://www.nature.com/articles/s41467-025-61084-7")[Wang et al., Nature Communications 2025], was originally built on the spirit of this reweight-annealing approach. It addresses a fundamental question: measurement can be viewed as a ratio of two partition functions, the numerator and denominator; since it is a ratio, it is naturally amenable to the reweight-annealing strategy. Although worm algorithms have been used in the past to compute off-diagonal observables, they are complicated, known only to a few experts, and restricted to specific models and algorithms. Our work provides a general framework for QMC practitioners, applicable to any algorithm and any model, to measure complex off-diagonal observables using this idea.

Although the BRA method, as an engineering route, can effectively address the measurement difficulty of off-diagonal observables and has achieved interesting results in system size and imaginary time, it still requires finding a reference point, designing a proper annealing path, and carefully controlling error accumulation and computational cost. These aspects can be overwhelming or even frustrating for a QMC practitioner.

=== Reduced density matrices as a language of many-body information

So we look back to the measurement. The density matrix is the central object in measurement. About 99% of the information of a quantum system is encoded in the density matrix, and the remaining 1% depends on how we postprocess it. The reduced density matrix is obtained by first tracing out the environment when it is irrelevant to the measurement. This step represents a qualitative leap for numerical measurements, because constructing the full density matrix typically requires exponential resources as the system size grows. Our generalized reduced-density-matrix QMC #link("https://arxiv.org/abs/2603.10948")[Wang et al., arXiv 2026] asks whether reduced density matrices, imaginary-time dynamics, entanglement, and correlation observables can be treated within a unified computational framework. Previous studies have performed various RDM calculations for equal-time correlations, many-body entanglement, and other quantities. Our breakthrough builds on these efforts by embedding imaginary-time evolution information into the RDM. This approach retains the polynomial-scaling advantage while directly providing access to off-diagonal imaginary-time observables.

We also performed a small benchmark for single-point imaginary-time tests. Considering measurement cost and accuracy, GRDM-QMC outperforms the BRA method by 85% to 94%. Even so, the BRA method may have an advantage over GRDM in computing off-diagonal quantities in domain-wall regions, such as disorder operators, whereas GRDM is constrained by the subsystem size defined by the RDM. I summarize the benchmark in #link("/Blog/2026-06-29-grdm-bra-benchmark/")[this short note].

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

  let full-journal-name(journal) = {
    let names = (
      "Nat. Commun.": "Nature Communications",
      "Phys. Rev. B": "Physical Review B",
      "Chin. Phys. Lett.": "Chinese Physics Letters",
    )

    names.at(journal, default: journal)
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
        #html.span(class: "publication-journal")[#full-journal-name(data.journal)],
        #data.year.
        #html.span(class: "publication-doi")[DOI: #link(data.url)[#data.doi]]
      ]
    ])
  }
}
