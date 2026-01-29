// Authors: MiniMax-M2.1🧙‍♂️, scillidan🤡

#let song = "Avalon (Sieren Remix) - Equador"
#let filename = sys.inputs.at("path", default: song)
#let name-only = filename.split("/").last().split(".").first()

#let cover-image = name-only + "_cover.jpg"
#let artist-image = name-only + "_artist.jpg"
#let lrc-file = name-only + ".lrc"
#let rawContent = read(lrc-file)
#let split-filename(name, sep: " - ") = {
  let parts = name.split(sep)
  if parts.len() > 1 {
    (parts.at(0), parts.slice(1).join(sep))
  } else {
    (name, "")
  }
}
#let (title, artist) = split-filename(name-only)
#let processLines(text) = {
  text
    .split("\n")
    .map(line => {
      line.replace(regex("^\[.+?\]"), "").trim()
    })
    .join("\n")
}
#let content = processLines(rawContent)

#set page("a5", flipped: true, margin: 5%)

#grid(
  columns: 2,
  gutter: 1em,
  [
    #block(
      width: 100%,
      height: 100%,
      grid(
        columns: 1,
        rows: (1fr, 1fr),
        gutter: 0.5em,
        align(center, box(
          width: 100%,
          height: 100%,
          stroke: 0.15pt + black,
          image(cover-image, width: 100%, height: 100%, fit: "contain"),
        )),
        align(center, box(
          width: 100%,
          height: 100%,
          stroke: 0.15pt + black,
          image(artist-image, width: 100%, height: 100%, fit: "contain"),
        ))
      )
    )
  ],
  [
    #block(
      width: 100%,
      height: 100%,
      inset: (x: 1em, y: 1em),
      {
        text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 1em, weight: "bold")[#title]
        linebreak()
        text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 1em, weight: "medium", style: "italic")[#artist]
        linebreak()
        v(0.5em)
        set text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 0.75em)
        for line in content.split("\n") {
          line
          linebreak()
        }
      }
    )
  ]
)
