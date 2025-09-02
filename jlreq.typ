#let jlreq-column-gap = state("jlreq-column-gap",1em)
#let jlreq-seriffont = state("jlreq-setriffont", "New Computer Modern")
#let jlreq-seriffont-cjk = state("jlreq-seriffont-cjk","Hiragino Mincho ProN")
#let jlreq-sansfont = state("jlreq-sansfont","New Computer Modern")
#let jlreq-sansfont-cjk = state("jlreq-sansfont-cjk","Hiragino Kaku Gothic ProN")
#let jlreq-non-cjk = state("jlreq-non-cjk", regex("[\u0000-\u2023]"))
#let jlreq-twoside = state("jlreq-twoside", false)


// return (textheight,topmargin,bottommargin)
// margin = space between border of the space and the main text

#let jlreq_gyodori(
  lines: 2,
  before_space: 0,
  after_space: 0,
  indent: 0em,
  end-indent: 0em,
  align: left,
  txt
) = {
  context{
    // 正しい？
    let column-gap = columns.gutter.length + columns.gutter.ratio * page.width
    // 和文文字の縦方向長さ
    let letter_height = measure(box[阿]).height
    // 段落間の長さ（block(spacing:**)のやつ）を計測
    let block_spacing = measure(block[#par[阿];#par[阿]]).height - 2 * letter_height
    // baselineskip
    let baselineskip = letter_height + par.leading
    let bef_sp = {
      if type(before_space) == int { before_space * baselineskip }
      else { before_space }
    }
    let aft_sp = {
      if type(after_space) == int { after_space * baselineskip }
      else { after_space }
    }
    // 行数指定がない場合
    if lines == none {
      block(
        spacing: 0pt,
        inset: (
          top: bef_sp,
          bottom: aft_sp,
          left: indent,
          right: end-indent,
        ),
        txt)
      return
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
    let b = block(spacing: 0cm, width: textlen, txt)
    // 長さ計算
    let total_len = baselineskip * lines + letter_height
    let ue = (total_len - measure(b).height)/2 + bef_sp
    let shita = (total_len - measure(b).height)/2 + aft_sp
    set std.align(align)
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

#let jlreq-tobira-heading(
  type: "han",
  header: auto,
  footer: auto,
  label-fmt: a => a,
  fmt: (l,b) => {
    v(1fr)
    text(size: 2em,weight: "bold",
      if l == none { b }
      else { l + h(1em) + b }
    )
    v(1fr)
  },
  head
) = {
  assert(type == "han" or type == "naka", 
    message: "jlreq-tobira-heading: type must be 'han' or 'naka'"
  )
  context{
    pagebreak()
    // 改丁
    if calc.rem-euclid(here().page(),2) == 0 { 
      set page(header: [], footer: [])
      h(0pt) // 入れるとなんかうまく行く
      pagebreak();
    }
    let origheader = page.header
    let origfooter = page.footer
    let cols = page.columns
    set page(columns: 1)
    let hc = { if header == auto { origheader} else { header}}
    let fc = { if footer == auto { origfooter} else { footer}}
    set page(
      header: hc,
      footer: fc,
      columns: 1
    )
    fmt(label-fmt([#counter(heading).display()]),head.body)
    pagebreak(weak: true)
    if type == "naka" {
      set page(header: [], footer: [])
      h(0pt)
      pagebreak()
    }
    set page(
      header: origheader,
      footer: origfooter,
      columns: cols
    )
  }
}

#let jlreq-block-heading(
  label-font: auto,
  label-font-weight: auto,
  label-font-cjk: auto,
  fontsize: 1em,
  label-fontsize: 1em,
  lines: 2,
  before-space: 0,
  after-space: 0,
  align: left,
  indent: 0em,
  after-label-space: 1em,
  end-indent: 0em,
  fmt: (l,b) => {
    if l == none { b }
    else { l + b }
  },
  pagestyle: "nariyuki",
  allowbreak_if_evenpage: false, // does not work currently
  head
) = {
  assert(
    pagestyle == "nariyuki" or
    pagestyle == "clearpage" or
    pagestyle == "cleardoublepage" or
    pagestyle == "clearcolumn"  or
    pagestyle == "begin_with_odd_page" or 
    pagestyle == "begin_with_even_page",
    message: "jlreq-block-heading: invalid pagestyle " + pagestyle
  )
  if pagestyle != "nariyuki" {
    if pagestyle == "clearcolumn" {
      colbreak(weak: true)
    } else {
      pagebreak(weak: true)
      if pagestyle != "clearpage" {
        let origheader = page.header
        let origfooter = page.footer
        // cleardoublepage = begin_with_odd_page
        let evenodd = {
          if pagestyle == "begin_with_even_page" { 1 }
          else { 0 }
        }
        if calc.rem-euclid(here().page(),2) == evenodd { 
          set page(header: [], footer: [])
          h(0pt)
          pagebreak();
          set page(
            header: origheader,
            footer: origfooter
          )
        }
      }
    }
  }

  let label = {
    if head.numbering != none {
      let cnt = [#counter(heading).display()]
      if label-font != auto or label-font-cjk != auto {
        if label-font == auto { label-font = jlreq-seriffont.get() }
        if label-font-cjk == auto { label-font-cjk = jlreq-seriffont-cjk.get() }
        cnt = text(font: label-font,cnt)
      }
      if label-font-weight != auto {
        cnt = text(weight: label-font-weight,cnt)
      }
      if label-fontsize != auto {
        cnt = text(size: label-fontsize,cnt)
      }
      cnt + h(after-label-space)
    } else { none }
  }

  jlreq_gyodori(
    lines: lines,
    before_space: before-space,
    after_space: after-space,
    indent: indent,
    end-indent: end-indent,
    align: align,
    fmt(label,head.body)
  )
}

#let jlreq-runin-heading(
  label-font: auto,
  label-font-weight: auto,
  label-fontsize: 1em,
  indent: 0em,
  after-label-space: 1em,
  label-fmt: a => a,
  after-space: 1em,
  head
) = {
  parbreak()
  h(indent - {
    if type(par.first-line-indent) == dictionary{
      par.first-line-indent.at("amount", default: 10pt)
    } else { par.first-line-indent } 
  })
  if head.numbering != none {
    let cnt = [#counter(heading).display()]
    if label-font != auto {
      cnt = text(font: label-font,cnt)
    }
    if label-font-weight != auto {
      cnt = text(weight: label-font-weight,cnt)
    }
    if label-fontsize != auto {
      cnt = text(size: label-fontsize,cnt)
    }
    cnt
    h(after-label-space)
  }
  head.body
  h(after-space)
}

// 偶数最後奇数最初

#let jlreq-get-header-footer(
  running-head-font: auto,
  running-head-font-cjk: auto,
  running-head-font-weight: auto,
  running-head-fontsize: 0.8em,
  nombre-font: auto,
  nombre-font-cjk: auto,
  nombre-font-weight: auto,
  nombre-fontsize: 0.8em,
  nombre: ((nombre: auto, position: bottom + center),),
  running-head: ((odd: none, even: none, position: top + left),),
  running-head-fmt: a => a.body,
  nombre-fmt: a => a,
  sidemargin: 0cm,
  nombre-gap: auto,
  running-head-gap: auto,
  gap: 1em,
) = {
  let get-real-running-head(runhead, odd) = {
    if runhead == none { return none }
    else if type(runhead) == int {
      let h = heading.where(level: runhead)
      if odd == true {
        return query(h.before(here())).at(-1,default: none)
      } else {
        return query(h.after(here())).at(0,default: none)
      }
    } else { return runhead }
  }

  let get-real-nombre(nombre) = {
    if nombre == none { return [] }
    else if nombre == auto { return counter(page).display() }
    else { return nombre }
  }

  if nombre-gap == auto { nombre-gap = gap }
  if running-head-gap == auto { running-head-gap = gap }
  //if running-head-font == auto { running-head-font = jlreq-seriffont.get() }
  //if running-head-font-cjk == auto { running-head-font-cjk = jlreq-seriffont-cjk.get() }
  //if nombre-font == auto { nombre-font = jlreq-sansfont.get() }
  //if nombre-font-cjk == auto { nombre-font-cjk = jlreq-sansfont-cjk.get() }

  if type(running-head) != array { running-head = (running-head,) }
  if type(nombre) != array { nombre = (nombre,) }

  let each-parts(pos) = {
    context{
      let non-cjk = jlreq-non-cjk.get()
      //twoside = falseの時は常にodd扱い
      let odd = {
        if jlreq-twoside.get() == true {calc.rem-euclid(here().page(),2) == 1 }
        else { true }
      }
      let runheads = {
        let i = 0;
        let rv = none;
        while(i < running-head.len()){
          if(type(running-head.at(i).at("position", default: top + center)) == pos){
            let runhead = {
              if odd == true {
                get-real-running-head(running-head.at(i).at("odd", default: none), true)
              } else {
                get-real-running-head(running-head.at(i).at("even", default: none), false)
              }
            }
            if runhead != none {
              runhead = text(font: ((name: running-head-font, covers: non-cjk), running-head-font-cjk),running-head-fmt(runhead))
              if running-head-fontsize != auto {
                runhead = text(size: running-head-fontsize, runhead)
              }
              if running-head-font-weight != auto {
                runhead = text(weight: running-head-font-weight, runhead)
              }
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
          if nombre.at(i).at("position", default: bottom + center) == pos {
            let nbr = get-real-nombre(nombre.at(i).at("nombre", default: none));
            if nbr != none {
              nbr = text(font: ((name: nombre-font, covers: non-cjk), nombre-font-cjk),nombre-fmt(nbr))
              if nombre-font-weight != auto {
                nbr = text(weight: nombre-font-weight, nbr)
              }
              if nombre-fontsize != auto {
                nbr = text(size: nombre-fontsize, nbr)
              }
              if rv == none { rv = nbr }
              else {
                rv = rv + h(nombre-gap) + nbr
              }
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
    return h(sidemargin) + connect(connect(l,c),r)
  }
  return (ueshita(top),ueshita(bottom))
}

#let jlreq-pagestyle(
  running-head-font: auto,
  running-head-font-cjk: auto,
  running-head-font-weight: auto,
  running-head-fontsize: 0.8em,
  nombre-font: auto,
  nombre-font-cjk: auto,
  nombre-font-weight: auto,
  nombre-fontsize: 0.8em,
  nombre: (nombre: auto, position: bottom + center),
  running-head: (odd: none, even: none, position: top + left),
  running-head-fmt: a => {
    numbering(a.numbering,counter(heading).at(a.location()).at(0))
    h(1em)
    a.body
  },
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
      running-head-font: runhead-font,
      running-head-font-cjk: runhead-font-cjk,
      running-head-font-weight: running-head-font-weight,
      running-head-fontsize: running-head-fontsize,
      nombre-font: nomb-font,
      nombre-font-cjk: nomb-font-cjk,
      nombre-font-weight: nombre-font-weight,
      nombre-fontsize: nombre-fontsize,
      nombre: nombre,
      running-head: running-head,
      running-head-fmt: running-head-fmt,
      nombre-fmt: nombre-fmt,
      sidemargin: sidemargin,
      nombre-gap: nombre-gap,
      running-head-gap: running-head-gap,
      gap: gap,
      )
    set page(header: h, footer: f)
    body
  }
}

#let jlreq(  
  seriffont: "New Computer Modern",
  seriffont-cjk: "Hiragino Mincho ProN", // or "Yu Mincho" or "Hiragino Mincho ProN"
  sansfont: "New Computer Modern",
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

  let papersizelist = (
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
  let jlreq_hposition_without_column(paperwidth,line-length,fore-edge,gutter) = {
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
  let jlreq_hposition(paperwidth,line-length,fore-edge,gutter,cols,column-gutter) = {
    let (tw,g,f) = jlreq_hposition_without_column(paperwidth,line-length,fore-edge,gutter)
    return (tw - (cols - 1) * column-gutter, g, f)
  }
  
  let jlreq_vposition(paperheight, fontsize, baselineskip, number-of-lines, head-space, foot-space, headsep) = {
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

  
  if baselineskip == auto { baselineskip = 1.75 * fontsize }
  let (paperwidth, paperheight) = {
    if type(paper) == str { papersizelist.at(paper) }
    else { paper }
  }
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

#let maketitle(
  authors: [],
  title: [],
  date: auto
) = {
  authors = {
    if type(authors) != array { (authors,) }
    else { authors }
  }
  if date == auto {
    date = datetime.today()
  }
  let datestr = {
    if date == none { none }
    else { [#date.year();年#date.month();月#date.day();日] }
  }
  let authorsstr = authors.fold(
    none,
    (a,b) => {
      if a == none { b }
      else { a + h(1em) +  b }
    }
  )

  context{
    v(4*(text.size + par.leading))
    stack(
      dir: ttb,
      spacing: 0.75em,
      align(center,{text(size: 2em, title)}),
      align(center,{text(size: 1em, authorsstr)}),
      if datestr != none { align(center, text(datestr)) }
    )
    v(text.size + par.leading)
  }


}