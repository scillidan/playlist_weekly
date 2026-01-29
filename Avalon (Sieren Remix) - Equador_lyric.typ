#let song = "Avalon (Sieren Remix) - Equador"
#let filename = sys.inputs.at("path", default: song).split("/").last().split(".").first()
#let split-filename(name, sep: " - ") = {
  let parts = name.split(sep)
  if parts.len() > 1 {
    (parts.at(0), parts.slice(1).join(sep))
  } else {
    (name, "")
  }
}
#let (title, artist) = split-filename(filename)
#let rawContent = read(song + ".lrc")
#let processLines(text) = {
  text
    .split("\n")
    .map(line => {
      line.replace(regex("^\[.+?\]"), "").trim()
    })
    .join("\n")
}
#let content = processLines(rawContent)

#set text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 9pt)

#text(weight: "bold", size: 2.5em, title)
#linebreak()
#v(0.5em)
#text(weight: "bold", style: "italic", size: 2em, artist)
#linebreak()
#v(1em)

#set par(leading: 0.76em, spacing: 1.5em)
#set text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 1.3em * 1.25)

#for line in content.split("\n") {
  line
  linebreak()
}
