import sys
import glob
import os

name = sys.argv[1]
basename = os.path.splitext(name)[0] if "." in name else name

artist_images = glob.glob(f"images/{basename}_artist*.jpg")
artist_images.sort()

if len(artist_images) == 0:
    artist_images = [f"images/{basename}_artist.jpg"]

artist_images_relative = [
    img.replace("images/", "../images/").replace("images\\", "../images/")
    for img in artist_images
]

artist_grid_items = ", ".join(
    [
        f'''align(center, box(
      width: 100%,
      height: 100%,
      stroke: 0.15pt + black,
      image("{img}", width: 100%, height: 100%, fit: "contain"),
    ))'''
        for img in artist_images_relative
    ]
)

artist_grid_content = (
    f"grid(columns: {len(artist_images)}, rows: (1fr,), gutter: 0.5em, {artist_grid_items})"
    if len(artist_images) > 1
    else f'''align(center, box(
      width: 100%,
      height: 100%,
      stroke: 0.15pt + black,
      image("{artist_images_relative[0]}", width: 100%, height: 100%, fit: "contain"),
    ))'''
)

content = f'''// Authors: MiniMax-M2.1🧙‍♂️, GLM-5🧙‍♂️, scillidan🤡

#let song = "{name}"
#let filename = sys.inputs.at("path", default: song)
#let name-only = filename.split("/").last().split(".").first()

#let cover-image = "../images/" + name-only + "_cover.jpg"
#let lrc-file = "../" + name-only + ".lrc"
#let rawContent = read(lrc-file)
#let split-filename(name, sep: " - ") = {{
  let parts = name.split(sep)
  if parts.len() > 1 {{
    (parts.at(0), parts.slice(1).join(sep))
  }} else {{
    (name, "")
  }}
}}
#let (title, artist) = split-filename(name-only)
#let processLines(text) = {{
  text
    .split("\\n")
    .map(line => {{
      line.replace(regex("^\\[(.+?)]"), "").trim()
    }})
    .join("\\n")
}}
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
        {artist_grid_content}
      )
    )
  ],
  [
    #block(
      width: 100%,
      height: 100%,
      inset: (x: 1em, y: 1em),
      {{
        text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 1em, weight: "bold")[#title]
        linebreak()
        text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 1em, weight: "medium", style: "italic")[#artist]
        linebreak()
        v(0.5em)
        set text(font: ("MonaspiceNe NFM", "Sarasa Mono SC"), size: 0.65em)
        for line in content.split("\\n") {{
          line
          linebreak()
        }}
      }}
    )
  ]
)'''

with open(f"typs/{name}.typ", "w", encoding="utf-8") as f:
    f.write(content)
