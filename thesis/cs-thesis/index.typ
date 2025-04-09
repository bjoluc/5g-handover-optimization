#let preface(body, title: "Preface Title") = {
  set par(justify: true)

  align(center + horizon)[
    #text(1.2em, weight: 600, title)
    
    #body
  ]

  pagebreak(to: "odd")
}

#let cs-thesis(
  universityLogo: [],
  documentName: [Bachelor/Master's Thesis],
  title: [The Title],
  facultyAndGroup: [The Faculty \ The Research Group],
  degree: "Bachelor/Master of Science",
  author: "The Author",
  advisor: "The Advisor",
  reviewers: ("The First Reviewer", "The Second Reviewer"),
  city: "City",
  submissionDate: "Submission Date",
  disclaimerTitle: [Disclaimer],
  disclaimerText: [
    I hereby declare that I prepared this thesis entirely on my own and have not used outside sources without declaration in the text.
    Any concepts or quotations applicable to these sources are clearly attributed to them.
    This thesis has not been submitted in the same or substantially similar version, not even in part, to any other authority for grading and has not been published elsewhere.
  ],
  disclaimerSignature: v(1.5em),
  preface: [],
  body,
) = context {
  set document(author: author, title: title)
  set page(
    margin: (inside: 2.5cm, outside: 2cm, y: 3cm),
    numbering: none,
  )
  set text(lang: "en", size: 12pt, ligatures: false)

  // Title page
  align(center)[
    #universityLogo

    #facultyAndGroup

    #v(1fr)
    #align(center, text(2em, weight: 700, title))
    #v(1fr)
    
    #text(1.5em, documentName) \

    in Partial Fulfillment of the Requirements for the \
    Degree of \
    #text(1.5em, degree)

    #v(1fr)

    by \
    #smallcaps(text(1.25em, author))

    #v(1fr)

    advised by \
    #text(1.25em, advisor)
    #v(1fr)

    submitted to \
    #text(1.25em, reviewers.at(0)) \
    and \
    #text(1.25em, reviewers.at(1))
    #v(1fr)

    #city, #submissionDate
  ]
  pagebreak(to: "odd")

  // Fonts
  set text(font: "New Computer Modern")

  // Font size
  show heading.where(level: 3): set text(size: 1.05em)
  show heading.where(level: 4): set text(size: 1.0em)
  show figure: set text(size: 0.9em)

  // Spacing
  set par(leading: 0.9em, first-line-indent: 1.8em, justify: true, spacing: 1em)

  show heading.where(level: 1): set block(above: 1.95em, below: 1em)
  show heading.where(level: 2): set block(above: 1.85em, below: 1em)
  show heading.where(level: 3): set block(above: 1.75em, below: 1em)
  show heading.where(level: 4): set block(above: 1.55em, below: 1em)

  // Equation numbering
  set math.equation(numbering: "(1)")

  // Heading numbering and names
  set heading(
    numbering: "1.1",
    supplement: it => {
      if (it.has("level")) {
        if it.level == 1 [Chapter]
        else [Section]
      }
    },
  )

  // https://github.com/typst/typst/issues/2722#issuecomment-2481508318
  show pagebreak: it => {
    [#metadata(none) <empty-page-start>]
    it
    [#metadata(none) <empty-page-end>]
  }

  let isPageEmpty() = {
    let pageNumber = here().page()
    query(selector.or(<empty-page-start>, <empty-page-end>)).chunks(2).any(((start, end)) => {
      start.location().page() < pageNumber and pageNumber < end.location().page()
    })
  }

  // Pagebreak before level 1 headings
  show heading.where(level: 1): it => [
    #pagebreak(weak: true, to: "odd")
    #it
  ]

  // Disclaimer
  align(horizon)[
    #text(disclaimerTitle, weight: 600, size: 1.4em)

    #par(disclaimerText, justify: true, first-line-indent: 0em)
  
    #v(3em)
    #grid(
      columns: 2,
      column-gutter: 1fr,
      row-gutter: 0.5em,
      align: center,
      grid.cell(
        rowspan: 3,
        [#city, #submissionDate],
      ),
      disclaimerSignature,
      line(length: 6cm, stroke: 0.5pt),
      author,
    )

    #pagebreak(to: "odd")
  ]

  preface

  set page(
    numbering: "i",
    // `scrbook`-style headings:
    header: context if not isPageEmpty() {
      let to-string(content) = {
        if content.has("text") {
          content.text
        } else if content.has("children") {
          content.children.map(to-string).join("")
        } else if content.has("child") {
          to-string(content.child)
        } else if content.has("body") {
          to-string(content.body)
        } else if content == [ ] {
          " "
        }
      }

      let currentPage = here().position().page
      let isCurrentPageLeft = calc.rem(currentPage, 2) == 0

      let primaryHeadingsOnThisPage = query(
        selector(heading.where(level: 1)).after(here())
      ).filter(heading => heading.location().page() < currentPage + 1)

      if primaryHeadingsOnThisPage.len() > 0 {
        // A primary heading is on this page - omitting the header
        return
      }
      
      let primaryHeadingsBeforeThisPage = query(
        selector(heading.where(level: 1)).before(here()),
      )
      if primaryHeadingsBeforeThisPage.len() == 0 {
        // No primary headings up to this point - omitting the header
        return
      }

      let primaryHeading = primaryHeadingsBeforeThisPage.last()

      if primaryHeading != none {
        if isCurrentPageLeft {
          if(primaryHeading.numbering != none) {
            numbering(primaryHeading.numbering, ..counter(heading).at(primaryHeading.location()))
            sym.space
          }
          smallcaps(to-string(primaryHeading.body))
        } else {
          // Find last secondary heading after the primary heading, up to this page
          let secondaryHeadingsUpToThisPage = query(
            selector(heading.where(level: 2)).after(primaryHeading.location()),
          ).filter(
            heading => heading.location().page() < currentPage + 1
          )

          if secondaryHeadingsUpToThisPage.len() > 0 {
            let lastSecondaryHeading = secondaryHeadingsUpToThisPage.last()
            let lastSecondaryHeadingNumber = numbering(heading.numbering, ..counter(heading).at(lastSecondaryHeading.location()))
            
            // lastSecondaryHeading.numbering
            align(right,
              text(
                style: "italic",
                lastSecondaryHeadingNumber + " " + to-string(lastSecondaryHeading)
              )
            )
          } else {
            // Some content to avoid layout divergence
            sym.space
          }
        }

        v(-0.8em)
        line(length: 100%, stroke: 0.5pt)
      }
    },

    // https://github.com/typst/typst/issues/1665
    footer: context if not isPageEmpty() {
      let isEvenPage = calc.even(here().position().page)
      set align(if isEvenPage { left } else { right })
      counter(page).display(page.numbering)
    },
  )

  counter(page).update(1)

  {
    show outline.entry.where(level: 1): it => strong(it)
    outline(
      title: "Contents",
      indent: 2em,
      depth: 3,
    )
  }

  if query(selector(figure.where(kind: image))).len() > 0 {
    outline(
      title: "List of Figures",
      target: figure.where(kind: image),
    )
  }

  if query(selector(figure.where(kind: table))).len() > 0 {
    outline(
      title: "List of Tables",
      target: figure.where(kind: table),
    )
  }

  pagebreak(weak: true, to: "odd")

  // Page numbering
  set page(numbering: "1")
  counter(page).update(1)

  // Table strokes: Draw only horizontal top and bottom line
  set table(stroke: (x, y) => (
    top: if y == 0 { 1pt } else { 0pt },
    bottom: 1pt,
  ))
  set table.hline(stroke: 0.5pt)

  // Table captions above tables
  show figure.where(kind: table): set figure.caption(position: top)

  // Figure spacing
  show figure.where(kind: image): set figure(gap: 1em)
  show figure: set block(above: 2em, below: 2em)

  // Equation spacing
  show math.equation: set block(spacing: 1.5em)

  // Enumerations and bullet lists
  set enum(numbering: "(1)", indent: 0.5em)
  show enum: set block(spacing: 1.5em)
  set list(indent: 0.5em)

  // Bibliography
  show bibliography: set par(leading: 0.7em)

  body
}