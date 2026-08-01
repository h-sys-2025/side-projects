module main

import os

const const_delims = "(){}[]<>,.?!:;=&|/\\@#$%^*'\" " // space also

//@ tok struct, with diagnostics info too!
struct Tokendiag {
  pub mut:
    kind string
    content string
    line i32
    col i32
}

//@ flexer is a simple tokenizer for programming languages!
fn main() {
  source_file_path := arguments()[1] or {
    eprintln("usage: ${arguments()[0]} <source-file.v>")
    return
  }

  u1 := source_file_path.split("/")
  if !u1[u1.len-1].ends_with(".v") {
    eprintln("${arguments()[0]}: only .v files are supported in this demo.")
    return
  }

  if !os.is_file(source_file_path) {
    eprintln("${arguments()[0]}: ${source_file_path} is not a valid file path.")
    return
  }

  contents := os.read_lines(source_file_path) or {
    eprintln("${arguments()[0]}: ${source_file_path} does not exist.")
    return
  }

  if contents.len < 1 {
    eprintln("${arguments()[0]}: ${source_file_path} seems to be empty.")
    return
  }

  // conclusion: source_file_path IS a valid file, and DOES contain data!
  // ---
  // task: Now convert contents into parts!

  mut ttokens := []string{}
  next_line: for i in 0..contents.len {
    // step 1: seperate the comments with actual code.
    line := contents[i].trim_space()
    if line == "" || line.starts_with("//") {
      continue next_line
    }
    // test: println("|${line}|")

    // step 2:
    tokens := tokenize(line)
    for tok in tokens {
      ttokens << tok
    }
    ttokens << "\\n"
  }
  // test: println(ttokens)

  // conclusion: awsome! it parses strings and other things easily!
  // ---
  // task: now to classify every token into its struct! with line-no:col-no info!

  mut lexed_program := []Tokendiag{}

  mut line_no := 0
  mut col_no  := 0
  mut tok_kind := ""
  next_tok: for tok in ttokens {
    if tok == "\\n" {
      line_no += 1
      col_no =  0 // new line's first col
      continue next_tok
    } else {
      col_no += 1
    }
    // test: println("${line_no}:${col_no}: ${tok}")
    if tok == " " {
      // tok is space!
      tok_kind = "SPACE"
    } else if tok in const_delims.str().split("") {
      // then tok is a special_char
      tok_kind = "SPECIAL_CHAR"
    } else if tok.contains("\"") {
      // then tok is a string literal
      tok_kind = "STRING_LITERAL"
    } else {
      tok_kind = "${tok.to_upper()}"
    }

    lexed_program << Tokendiag{
      kind: tok_kind
      content: tok
      line: line_no
      col: col_no
    }

    tok_kind = ""
  }

  // test: println(parsed_program)

  // conclusion: ok, now they are classifies!
  // ---
  // task:

  mut parsed_program := Parser{items: lexed_program}
  mut statement := ""
  for i in 0.. parsed_program.items.len {
    thing   := parsed_program.items[i]

    line_no = thing.line
    col_no  = thing.col

    if thing.kind == "fn" {
      // this it is tok_fn
      tok_fn := thing
      // thing+1 is name.
      name   := parsed_program.next()
      // thing+2 is (
      parsed_program.expect("(")
      // thing+x must be args
      args_block := parsed_program.parse_block("()")
      // thing+x+1 is )
      parsed_program.expect("(")
      // thing+x+2 is ret_type
      parsed_program.next()
      // thing+x+3 is {
      parsed_program.expect("{")
      // thing+x+3+y must be body!
      code_block := parsed_program.parse_block("{}")
      // thing+x+3+y+1 is }
      parsed_program.expect("}")

      // now THAT we call a function
    }
  }

  return
}

struct Parser {
  pub mut:
    line int
    col int
    curr_pointer int
    items []Tokendiag
}

pub fn (mut p Parser) expect(thing string) (bool, Tokendiag) {
  la_item := p.items[p.curr_pointer]
  if la_item.str() == thing {
    p.curr_pointer += 1
    return true, la_item
  } else {
    panic("${p.line}:${p.col}: expected `${thing}` but got `${la_item}`")
    return false, la_item
  }
}

pub fn (mut p Parser) next() Tokendiag {
  la_item := p.items[p.curr_pointer]
  p.curr_pointer += 1
  return la_item
}

//@ this function tokenizes every token, identifier, int literal, float literal, boolean, keyword, and these ( ) { } [ ] < > , . ? !
fn tokenize(line string) []string {
  mut raw_data := line

  ttokens := const_delims
  for tok in ttokens.str().split("") {
    // test: println("seperator: ${tok.str()}")
    raw_data = raw_data.split(tok.str()).join("\n${tok.str()}\n")
  }


  // now CLASSIFY them into token types.
  mut tokens := []string{}

  // make: strings
  mut str_started := false
  mut str_make_temp := ""
  next_tok: for x in raw_data.str().split("\n") {
    if x == "" {
      continue next_tok
    }

    if x == "\"" {
      str_started = !str_started
      continue next_tok
    }

    if str_started {
      str_make_temp = "${str_make_temp}${x}"
    } else {
      if str_make_temp != "" {
        tokens << "\"${str_make_temp}\""
        str_make_temp = ""
      }
    }

    if !str_started {
      tokens << "${x}"
    }
  }

  return tokens
}