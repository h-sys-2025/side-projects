module main

import os

fn main() {
  source := "./test1.c" // OR: arguments()[1] or {return}
  contents := os.read_lines(source) or {
    eprintln(err)
    return
  }

  mut generated_code := []string{}
  for x in 0..contents.len {
    line := contents[x].trim_space()
    if line.starts_with("fn") {

      mut parts := line
      for delim in "!@#$%^&*()_+-={}[]::\"'<>,.?/|\\ ".str().split("") {
        parts = parts.split(delim).join("\n${delim}\n")
      }

      tttokens := parts.split("\n")
      mut tokens := []string{}
      for tok in tttokens {
        if tok != "" {
          tokens << tok
        }
      }
      // debug: println(tokens)
      for i in 0..tokens.len {
        token := tokens[i]
        if token == "fn" {
          mut offset := 0
          // startign of a function
          offset += 2
          name := tokens[i+offset]
          mut generic := ""
          offset += 1
          if tokens[i+offset] == "<" {
            // then this is a generic function
            offset += 1
            generic = "<${tokens[i+offset]}>"
            offset += 1
            tmptok := tokens[i+offset]
            if tmptok != ">" {
              eprintln("${x+1}:${i}: expected `>` got `${tmptok}`")
              // return
            }
            offset += 1
          }

          tmp_args_tok := tokens[i+offset]
          mut args_data := ""
          if tmp_args_tok == "(" {
            args_data = "("
            for {
              offset += 1
              next_tok := tokens[i+offset]
              if next_tok != ")" {
                args_data = "${args_data}${next_tok}"
              } else {
                args_data = "${args_data})"
                break
              }
            }
          } else {
            eprintln("${x+1}:${i}: expected `(` got `${tmp_args_tok}`")
            // return
          }

          mut func_def := []string{}
          mut depth := 1
          for {
            offset += 1

            if i+offset > tokens.len-1 {
              break
            }

            tmp_lbrace_tok := tokens[i+offset]


            // debug: println("tmp: ${tmp_lbrace_tok}")
            if tmp_lbrace_tok == "{" {
              func_def << "{"
              depth += 1
            } else if tmp_lbrace_tok == "}" {
              func_def << "}"
              depth -= 1
              if depth < 1 {
                break
              }
            } else if depth > 0 {
              func_def << tmp_lbrace_tok
            }
          }

          // TBD: convert to C

          out_ln := "Any_t ${name}${args_data.replace("T","Any_t")} ${func_def.join("")}"
          // debug: println(out_ln)
          generated_code << out_ln
        }
      }
    } else {
      generated_code << "${line}"
    }
  }

  println(generated_code.join("\n"))
  return
}