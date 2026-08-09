// Reusable lyric-poster template.
// Imported and called by the per-song .typ files under _output/pdfs/.

#let default-font = ("MonaspiceNe NFM", "Sarasa Mono SC")

// Render a single image so it fills its cell without overflowing.
#let image-box(path) = {
  if path == none or path == "" {
    return []
  }
  box(
    width: 100%,
    height: 100%,
    stroke: 0.15pt + black,
    image(path, width: 100%, height: 100%, fit: "contain"),
  )
}

// Strip LRC timestamps like [00:12.34] from the start of each line.
#let process-lrc(path) = {
  if path == none or path == "" {
    return ""
  }
  let raw = read(path)
  raw
    .split("\n")
    .map(line => line.replace(regex("^\\[(.+?)]"), "").trim())
    .join("\n")
}

// Lay out artist photos in an NxN grid, left-to-right, top-to-bottom.
// If cols/rows are not set, default to a single row with all images.
#let artist-grid(paths, cols: none, rows: none, gutter: 0.5em) = {
  if paths.len() == 0 {
    return []
  }
  let n = paths.len()
  let c = if cols != none {
    cols
  } else if rows != none {
    calc.ceil(n / rows)
  } else {
    n
  }
  let r = if rows != none {
    rows
  } else {
    calc.ceil(n / c)
  }
  grid(
    columns: (1fr,) * c,
    rows: (1fr,) * r,
    gutter: gutter,
    ..paths.map(image-box),
  )
}

// Main entry point.
#let lyric-poster(
  name: "",
  cover: none,
  artists: (),
  lrc: none,
  left-ratio: 0.35,
  lyrics-columns: 1,
  lyrics-column-widths: none,
  lyrics-columns-split: none,
  lyrics-size: 0.55em,
  lyrics-wrap-leading: none,       // line height only when a lyric line wraps
  lyrics-spacing: 5pt,             // gap between lyric lines
  lyrics-paragraph-spacing: 1em,   // gap for blank lines / verses in the LRC
  lyrics-inset: (top: 0pt, left: 0pt),
  image-inset: (top: 0pt, left: 0pt),
  spacing_all: 10pt,                // page margin + image/lyrics gutter + lyrics column gutter
  artist-grid-cols: none,          // artist image grid columns (default: single row)
  artist-grid-rows: none,          // artist image grid rows
  page-size: "a5",
  flipped: true,
  font: default-font,
) = {
  let lyrics-raw = process-lrc(lrc)
  let lyrics-lines = lyrics-raw.split("\n")

  let has-cover = cover != none and cover != ""
  let has-artists = artists.len() > 0
  let has-images = has-cover or has-artists

  set page(page-size, flipped: flipped, margin: spacing_all)
  set text(font: font)

  // Reusable title line (hard-coded 1em size, all bold).
  let title-block = {
    text(size: 1em, weight: "bold")[#name]
    v(spacing_all - 0.5em)
  }

  // Helper to render a slice of lyric lines.
  let render-lyrics(lines) = {
    set text(size: lyrics-size)
    // hanging-indent indents wrapped continuation lines by 2 characters.
    let par-args = (
      justify: false,
      hanging-indent: 2em,
      spacing: lyrics-spacing,
    )
    if lyrics-wrap-leading != none {
      par-args = par-args + (leading: lyrics-wrap-leading)
    }
    set par(..par-args)

    for line in lines {
      if line.trim() == "" {
        v(lyrics-paragraph-spacing)
      } else {
        line
        parbreak()
      }
    }
  }

  // Right-hand lyrics area, reusable whether or not there are images.
  let lyrics-area = [
    #block(
      width: 100%,
      height: 100%,
      inset: lyrics-inset,
      {
        let use-custom-widths = lyrics-column-widths != none and lyrics-column-widths.len() > 0
        let use-splits = lyrics-columns-split != none and lyrics-columns-split.len() > 0

        let widths = if use-custom-widths {
          lyrics-column-widths
        } else {
          (1fr,) * lyrics-columns
        }
        let n = widths.len()
        let split-points = if use-splits {
          lyrics-columns-split
        } else {
          let chunk = calc.ceil(lyrics-lines.len() / n)
          range(n - 1).map(i => calc.min((i + 1) * chunk, lyrics-lines.len()))
        }
        let bounds = (0,) + split-points + (lyrics-lines.len(),)

        grid(
          columns: widths,
          rows: (auto, 1fr),
          gutter: spacing_all,
          // Row 1: title in the first column, empty in the other columns.
          ..range(n).map(i => if i == 0 { title-block } else { [] }),
          // Row 2: lyrics for each column, all aligned below the title row.
          ..range(n).map(i => render-lyrics(lyrics-lines.slice(bounds.at(i), bounds.at(i + 1)))),
        )
      },
    )
  ]

  if has-images {
    grid(
      columns: (left-ratio * 1fr, (1 - left-ratio) * 1fr),
      gutter: spacing_all,

      // Left: image area.
      [
        #block(
          width: 100%,
          height: 100%,
          inset: image-inset,
          {
            if has-cover and has-artists {
              grid(
                columns: 1,
                rows: (1fr, 1fr),
                gutter: 5pt,
                image-box(cover),
                artist-grid(artists, cols: artist-grid-cols, rows: artist-grid-rows, gutter: 5pt),
              )
            } else if has-cover {
              image-box(cover)
            } else if has-artists {
              artist-grid(artists, gutter: 5pt)
            }
          },
        )
      ],

      // Right: lyrics area.
      lyrics-area,
    )
  } else {
    // No images: lyrics span the whole width.
    lyrics-area
  }
}
