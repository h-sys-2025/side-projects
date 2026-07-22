module main

import os

//@ tok struct, with diagnostics info too!
struct tokendiag {
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



  return
}

//@ this function tokenizes every token, identifier, int literal, float literal, boolean, keyword, and these ( ) { } [ ] < > , . ? !
fn tokenize(line string) []string {
  mut raw_data := line

  ttokens := "(){}[]<>,.?!:;=&|/\\@#$%^*'\" " // space also
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
    } else {
      tokens << "${x}"
    }

    if str_started {
      str_make_temp = "${str_make_temp}${x}"
      continue next_tok
    } else {
      if str_make_temp != "" {
        tokens << "\"${str_make_temp}\""
        str_make_temp = ""
        continue next_tok
      }
      continue next_tok
    }
  }

  return tokens
}