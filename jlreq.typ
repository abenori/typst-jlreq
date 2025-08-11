// Template based on LaTeX jsarticle/jsbook for Typst 0.13

#let jlreq-column-gap = state("jlreq-column-gap",1em)
#let jlreq-seriffont = state("jlreq-setriffont", "New Computer Modern")
#let jlreq-seriffont-cjk = state("jlreq-seriffont-cjk","Hiragino Mincho ProN")
#let jlreq-sansfont = state("jlreq-sansfont","New Computer Modern")
#let jlreq-sansfont-cjk = state("jlreq-sansfont-cjk","Hiragino Kaku Gothic ProN")
#let jlreq-non-cjk = state("jlreq-non-cjk", regex("[\u0000-\u2023]"))
#let jlreq-twoside = state("jlreq-twoside", false)

#let papersizelist = (
  a0paper: (841mm,1189mm),
  a1paper: (594mm,841mm),
  a2paper: (420mm,594mm),
  a3paper: (297mm,420mm),
  a4paper: (210mm,297mm),
  a5paper: (148mm,210mm),
  a6paper: (105mm,148mm),
  a7paper: (74mm,105mm),
  a8paper: (52mm,74mm),
  a9paper: (37mm,52mm),
  a10paper: (26mm,37mm),
  a0: (841mm,1189mm),
  a1: (594mm,841mm),
  a2: (420mm,594mm),
  a3: (297mm,420mm),
  a4: (210mm,297mm),
  a5: (148mm,210mm),
  a6: (105mm,148mm),
  a7: (74mm,105mm),
  a8: (52mm,74mm),
  a9: (37mm,52mm),
  a10: (26mm,37mm),

  b0paper: (1000mm,1414mm),
  b1paper: (707mm,1000mm),
  b2paper: (500mm,707mm),
  b3paper: (353mm,500mm),
  b4paper: (250mm,353mm),
  b5paper: (176mm,250mm),
  b6paper: (125mm,176mm),
  b7paper: (88mm,125mm),
  b8paper: (63mm,88mm),
  b9paper: (44mm,63mm),
  b10paper: (31mm,44mm),

  b0j: (1030mm,1456mm),
  b1j: (728mm,1030mm),
  b2j: (515mm,728mm),
  b3j: (364mm,515mm),
  b4j: (257mm,364mm),
  b5j: (182mm,257mm),
  b6j: (128mm,182mm),
  b7j: (91mm,128mm),
  b8j: (64mm,91mm),
  b9j: (45mm,64mm),
  b10j: (32mm,45mm),

  c2paper: (458mm,648mm),
  c3paper: (324mm,458mm),
  c4paper: (229mm,324mm),
  c5paper: (162mm,229mm),
  c6paper: (114mm,162mm),
  c7paper: (81mm,114mm),
  c8paper: (57mm,81mm),

  a4var: (210mm,283mm),
  b5var: (182mm,230mm),

  letterpaper: (8.5in,11in),
  legalpaper: (8.5in,14in),
  executivepaper: (7.25in,10.5in),
  hagaki: (100mm,148mm),

  ansiapaper: (8.5in,11in),
  ansibpaper: (11in,17in),
  ansicpaper: (17in,22in),
  ansidpaper: (22in,34in),
  ansiepaper: (34in,44in),
)

#let jlreq_paper(paper) = {
  if type(paper) == str { paper = papersizelist.at(paper) }
  return paper
}

#let jlreq_hposition_without_column(paperwidth,line-length,fore-edge,gutter) = {
  assert((line-length == auto) or (fore-edge == auto) or (gutter == auto),
    message: "jlreq error: one of line-length, fore-edge, gutter must be auto")
  if gutter != auto and fore-edge != auto { return (paperwidth - gutter - fore-edge,gutter,fore-edge) }
  if line-length == auto { line-length = 0.75 * paperwidth }
  if gutter != auto { return (line-length, gutter, paperwidth - line-length - gutter) }
  else if fore-edge != auto { return (line-length, paperwidth - line-length - fore-edge, fore-edge) }
  else {
    let margin = (paperwidth - line-length) / 2
    return (line-length, margin, margin)
  }
}

// return (textwidth, gutter, fore-edge)
#let jlreq_hposition(paperwidth,line-length,fore-edge,gutter,cols,column-gutter) = {
  let (tw,g,f) = jlreq_hposition_without_column(paperwidth,line-length,fore-edge,gutter)
  return (tw - (cols - 1) * column-gutter, g, f)
}

// return (textheight,topmargin,bottommargin)
// margin = space between border of the space and the main text
#let jlreq_vposition(paperheight, fontsize, baselineskip, number-of-lines, head-space, foot-space, headsep) = {
  assert((number-of-lines == auto) or (head-space == auto) or (foot-space != auto),
    message: "jlreq error: one of number-of-lines, head-space, foot-space must be auto")
  let header-size = fontsize
  if head-space != auto and foot-space != auto {
    return (
      paperheight - head-space - foot-space - 2 * header-size - 2 * headsep,
      head-space + header-size + headsep,
      foot-space + header-size + headsep)
  }
  let textheight = {
    if number-of-lines == auto { 0.75 * paperheight }
    else { baselineskip * (number-of-lines - 1) + fontsize }
  }
  if head-space != auto {
    return (textheight,head-space + headier-size + headsep,
      paperheight - textheight - head-space - headsep - header-size)
  } else if foot-space != auto {
    return (textheight, 
      paperheight - textheight - foot-space - headsep - header-size,
      foot-space + header-size + headsep)
  } else {
    let margin = (paperheight - textheight) / 2
    return (textheight,margin,margin)
  }
}

#let jlreq_gyodori(
  lines: 2,
  before_space: 0,
  after_space: 0,
  indent: 0em,
  end-indent: 0em,
  al: left,
  txt
) = {
  context{
    let column-gap = jlreq-column-gap.get()
    // 和文文字の縦方向長さ
    let letter_height = measure(box[阿]).height
    // 段落間の長さ（block(spacing:**)のやつ）を計測
    let block_spacing = measure(block[#par[阿];#par[阿]]).height - 2 * letter_height
    // baselineskip
    let baselineskip = letter_height + par.leading
    let be_sp = {
      if type(before_space) == int { before_space * baselineskip }
      else { before_space }
    }
    let aft_sp = {
      if type(after_space) == int { after_space * baselineskip }
      else { after_space }
    }
    // 本文のテキスト長さの計算
    let textlen = {
      let totaltextlen = {
        page.width - {
          if page.margin == auto {
            (5/21) * {
              if page.width < page.height { page.width}
              else { page.height }
            }
          } else if(type(page.margin)) == dictionary {
            let margin_keys = page.margin.keys()
            let left_margin = {
              if(margin_keys.contains("left")) {
                page.margin.left
              } else if(margin_keys.contains("inside")){
                page.margin.inside
              } else { 0pt }
            }
            let right_margin = {
              if(margin_keys.contains("right")){
                page.margin.right
              } else if(margin_keys.contains("outside")){
                page.margin.outside
              } else { 0pt }
            }
            right_margin + left_margin
          } else { 2 * page.margin }
        }
      }
      (totaltextlen -  (page.columns - 1) * column-gap)/page.columns - indent - end-indent
    }
    
    // とりあえずブロックに入れる
    let b = block(spacing: 0cm, 
    //inset: (left: indent, right: end-indent), 
    width: textlen, txt)
    // 長さ計算
    let total_len = baselineskip * (lines - 1) + letter_height
    let ue = (total_len - measure(b).height)/2 + be_sp
    let shita = (total_len - measure(b).height)/2 + aft_sp
    set align(al)
    block(
      spacing: 0pt,
      inset: (
        top: ue,
        bottom: shita,
        left: indent,
        right: end-indent,
      ),
      b)
  }
}

#set heading(numbering: "1")

#let jlreq-block-heading(
  font: auto,
  font-cjk: auto,
  font-weight: "bold",
  label-font: auto,
  label-font-weight: "bold",
  label-font-cjk: auto,
  fontsize: 1em,
  label-fontsize: 1em,
  lines: 2,
  before_space: 0,
  after_space: 0,
  align: left,
  indent: 0em,
  after-label-space: 1em,
  end-indent: 0em,
  it
) = {
  let non-cjk = jlreq-non-cjk.get()
  if font == auto { font = jlreq-sansfont.get() }
  if font-cjk == auto { font-cjk = jlreq-sansfont-cjk.get() }
  if label-font == auto { label-font = jlreq-sansfont.get() }
  if label-font-cjk == auto { label-font-cjk = jlreq-sansfont-cjk.get() }
  let label-font-set = ((name: label-font, covers: non-cjk), font-cjk)
  let font-set = ((name: font, covers: non-cjk), font-cjk)
  jlreq_gyodori(
    lines: lines,
    before_space: before_space,
    after_space: after_space,
    indent: indent,
    end-indent: end-indent,
    al: align,
  {
    if it.numbering != none {
      text(font: label-font-set, size: label-fontsize, weight: label-font-weight)[#counter(heading).display()]
      h(after-label-space)
    }
    text(font: label-font-set, size: fontsize, weight: font-weight)[#it.body]
  })
}

// 偶数最後奇数最初
#let get-real-running-head(runhead, odd) = {
  if runhead == none { return none }
  else if type(runhead) == int {
    context {
      let h = heading.where(level: runhead)
      if odd == true {
        return query(h.before(here())).at(-1,default: none)
      } else {
        return query(h.after(here())).at(0,default: none)
      }
    }
  } else { return runhead }
}

#let get-real-nombre(nombre) = {
  context{
    if nombre == none { return [] }
    else if nombre == auto { return counter(page).display() }
    else { return nombre }
  }
}

#let jlreq-get-header-footer(
  running-head-font: auto,
  running-head-font-cjk: auto,
  running-head-font-weight: "regular",
  running-head-fontsize: 1em,
  nombre-font: auto,
  nombre-font-cjk: auto,
  nombre-font-weight: "bold",
  nombre-fontsize: 1em,
  nombre: auto,
  odd-running-head: none,
  even-running-head: none,
  running-head-position: top + left,
  nombre-position: bottom + center,
  running-head-fmt: a => a,
  nombre-fmt: a => a,
  sidemargin: 0cm,
  nombre-gap: auto,
  running-head-gap: auto,
  gap: 1.5cm,

) = {
  if nombre-gap == auto { nombre-gap = gap }
  if running-head-gap == auto { running-head-gap = gap }
  //if running-head-font == auto { running-head-font = jlreq-seriffont.get() }
  //if running-head-font-cjk == auto { running-head-font-cjk = jlreq-seriffont-cjk.get() }
  //if nombre-font == auto { nombre-font = jlreq-sansfont.get() }
  //if nombre-font-cjk == auto { nombre-font-cjk = jlreq-sansfont-cjk.get() }

  if type(odd-running-head) != array { odd-running-head = (odd-running-head,) }
  if type(even-running-head) != array { even-running-head = (even-running-head,) }
  if type(nombre) != array { nombre = (nombre,) }
  if type(running-head-position) != array { running-head-position = (running-head-position,) }
  if type(nombre-position) != array { nombre-position = (nombre-position,) }

  let each-parts(pos) = {
    context{
      //twoside = falseの時は常にodd扱い
      let odd = {
        if jlreq-twoside.get() == true {calc.rem-euclid(here().page(),2) == 1 }
        else { true }
      }
      let runheads = {
        let i = 0;
        let rv = none;
        while(i < odd-running-head.len()) {
          if(running-head-position.at(i, default: top + center) == pos){
            let runhead = {
              if odd == true {
                get-real-running-head(odd-running-head.at(i,default: none), true)
              } else {
                get-real-running-head(even-running-head.at(i,default: none), false)
              }
            }
            if runhead != none { 
              if rv == none { rv = runhead }
              else { rv = rv + h(running-head-gap) + runhead }
            }
          }
          i = i + 1
        }
        rv
      }
      let nombres = {
        let i = 0
        let rv = none
        while(i < nombre.len()){
          if nombre-position.at(i, default: bottom + center) == pos {
            let n = get-real-nombre(nombre.at(i, default: none));
            if n != none {
              if rv == none { rv = n }
              else { rv = rv + h(nombre-gap) + n }
            }
          }
          i = i + 1
        }
        rv
      }


      return {
        if runheads == none {
          if nombres == none {
            none
          } else {
            nombres
          }
        }else {
          if nombres == none {
            runheads
          } else {
            if odd == true {
              nombres + h(gap) + runheads
            } else {
              runheads * h(gap) + nombres
            }
          }
        }
      }
    }
  }
  let ueshita(pos) = {
    let l = each-parts(pos.y + left)
    let c = each-parts(pos.y + center)
    let r = each-parts(pos.y + right)
    let connect(a,b) = {
      if a == none {
        if b == none { none }
        else { h(1fr) + b }
      } else {
        if b == none { a }
        else { a + h(1fr) + b }
      }
    }
    return connect(connect(l,c),r)
  }
  return (ueshita(top),ueshita(bottom))
}

#let jlreq-pagestyle(
  running-head-font: auto,
  running-head-font-cjk: auto,
  running-head-font-weight: "regular",
  running-head-fontsize: 1em,
  nombre-font: auto,
  nombre-font-cjk: auto,
  nombre-font-weight: "bold",
  nombre-fontsize: 1em,
  nombre: auto,
  odd-running-head: none,
  even-running-head: none,
  running-head-position: top + left,
  nombre-position: bottom + center,
  running-head-fmt: a => a,
  nombre-fmt: a => a,
  sidemargin: 0cm,
  nombre-gap: auto,
  running-head-gap: auto,
  gap: 1.5cm,
  body
) = {
  context{
    let runhead-font = {
      if running-head-font == auto { jlreq-sansfont.get() }
      else { running-head-font }
    }
    let runhead-font-cjk = {
      if running-head-font-cjk == auto { jlreq-sansfont-cjk.get() }
      else { running-head-font-cjk }
    }
    let nomb-font = {
      if nombre-font == auto { jlreq-sansfont.get() }
      else { nombre-font }
    }
    let nomb-font-cjk = {
      if nombre-font-cjk == auto { jlreq-sansfont-cjk.get() }
      else { nombre-font-cjk }
    }
    let (h,f) = jlreq-get-header-footer(
      running-head-font:   runhead-font,
      running-head-font-cjk:   runhead-font-cjk,
      running-head-font-weight:   running-head-font-weight,
      running-head-fontsize:   running-head-fontsize,
      nombre-font:   nomb-font,
      nombre-font-cjk:   nomb-font-cjk,
      nombre-font-weight:   nombre-font-weight,
      nombre-fontsize:   nombre-fontsize,
      nombre:   nombre,
      odd-running-head:   odd-running-head,
      even-running-head:   even-running-head,
      running-head-position:   running-head-position,
      nombre-position:   nombre-position,
      running-head-fmt:   running-head-fmt,
      nombre-fmt:   nombre-fmt,
      sidemargin:   sidemargin,
      nombre-gap:   nombre-gap,
      running-head-gap:   running-head-gap,
      gap:   gap,
      )
    set page(header: h, footer: f)
    body
  }
}

#let jlreq(  
  seriffont: "New Computer Modern", // or "Libertinus Serif" or "Source Serif Pro"
  seriffont-cjk: "Hiragino Mincho ProN", // or "Yu Mincho" or "Hiragino Mincho ProN"
  sansfont: "New Computer Modern", // or "Arial" or "New Computer Modern Sans" or "Libertinus Sans"
  sansfont-cjk: "Hiragino Kaku Gothic ProN", // or "Yu Gothic" or "Hiragino Kaku Gothic ProN"
  fontsize: 10pt,
  baselineskip: auto,
  // 基本版面
  paper: "a4",
  line-length: auto,
  number-of-lines: auto,
  fore-edge: auto,
  gutter: auto,
  column-gap: 1em,
  head-space: auto,
  foot-space: auto,
  headsep: 1em,

  twoside: false,
  cols: 1,
  non-cjk: regex("[\u0000-\u2023]"), // or "latin-in-cjk"
  cjkheight: 0.88, // height of CJK in em
  body
) = {
  jlreq-column-gap.update(column-gap)
  jlreq-seriffont.update(seriffont)
  jlreq-seriffont-cjk.update(seriffont-cjk)
  jlreq-sansfont.update(sansfont)
  jlreq-sansfont-cjk.update(sansfont-cjk)
  jlreq-non-cjk.update(non-cjk)
  jlreq-twoside.update(twoside)

  if baselineskip == auto { baselineskip = 1.75 * fontsize }
  let (paperwidth, paperheight) = jlreq_paper(paper)
  let (textwidth, g,f) = jlreq_hposition(paperwidth, line-length, fore-edge, gutter, cols, column-gap)
  let (textheight, topmargin, bottommargin) = jlreq_vposition(paperheight, fontsize, baselineskip, number-of-lines, head-space, foot-space,headsep)
  set columns(gutter: column-gap * 2)
  set page(
    width: paperwidth,
    height: paperheight,
    columns: cols,
    numbering: "1",
  )
  let mar = {
    if twoside == true {
      (
        inside: g,
        outside: f,
        top: topmargin,
        bottom: bottommargin,
      )
    } else {
      (
        left: g,
        right: f,
        top: topmargin,
        bottom: bottommargin,
      )
    }
  }
  set page(margin: mar)
  set text(
    lang: "ja",
    font: ((name: seriffont, covers: non-cjk), seriffont-cjk),
    weight: 450,
    size: fontsize,
    top-edge: cjkheight * fontsize,
  )
  set par(
    first-line-indent: (amount: 1em, all: true),
    justify: true,
    spacing: baselineskip - cjkheight * fontsize, // space between paragraphs
    leading: baselineskip - cjkheight * fontsize, // space between lines
  )
  set heading(numbering: "1.1")
  show heading: set text(
    font: ((name: sansfont, covers: non-cjk), sansfont-cjk),
    weight: "bold",
    size: fontsize,
  )
  set enum(numbering: "(1.1)")
  body
}