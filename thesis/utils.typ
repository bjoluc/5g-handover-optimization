// Shortcut for table hlines with additional spacing
#let hline(columns: 2) = {
  return (
    table.cell(colspan: columns, inset: 1.5pt)[],
    table.hline(),
    table.cell(colspan: columns, inset: 1.5pt)[],
  )
}

#let hgap(columns: 2) = {
  return (
    table.cell(colspan: columns, inset: 1.5pt)[],
  )
}

#let nobreak() = {
  [\u{2060}]
}

// https://github.com/typst/typst/issues/2873#issuecomment-2138261314
#let pageref(label) = context {
  let loc = locate(label)
  let nums = counter(page).at(loc)
  link(loc, numbering(loc.page-numbering(), ..nums))
}
