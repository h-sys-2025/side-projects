module main

//@ the simplest json lib in all v ecosystem.
import x.json2

//@ toktypes.
enum TokenType {
  lparen
  rparen
  literal
}

//@ token struct.
struct Token {
  typ TokenType
  val string
}

//@ tokenize(string) []Token
//@ tokenize splits the Lisp string into structural and literal tokens
fn tokenize(code string) []Token {
  mut tokens := []Token{}
  mut i := 0
  for i < code.len {
    ch := code[i]
    if ch == ` ` || ch == `\t` || ch == `\n` || ch == `\r` {
      i++
      continue
    }
    if ch == `(` {
      tokens << Token{typ: .lparen, val: "("}
      i++
    } else if ch == `)` {
      tokens << Token{typ: .rparen, val: ")"}
      i++
    } else if ch == `"` {
      // Handle string literals
      mut start := i
      i++ // skip opening quote
      for i < code.len && code[i] != `"` {
        i++
      }
      if i < code.len {
        i++ // skip closing quote
      }
      tokens << Token{typ: .literal, val: code[start..i]}
    } else {
      // Handle atoms, identifiers, and numbers
      mut start := i
      for i < code.len && code[i] != ` ` && code[i] != `(` && code[i] != `)` && code[i] != `\n` && code[i] != `\t` && code[i] != `\r` {
        i++
      }
      tokens << Token{typ: .literal, val: code[start..i]}
    }
  }
  return tokens
}

//@ parse_expression([]Token, mut &int) json2.Any
//@ parse_expression recursively builds a json2.Any tree from tokens
fn parse_expression(tokens []Token, mut index &int) json2.Any {
  if unsafe { *index } >= tokens.len {
    return ""
  }

  token := tokens[unsafe { *index }]

  if token.typ == .literal {
    unsafe { *index += 1 }
    val := token.val

    // Safely check for integer literals
    if val.bytes().all(it.is_digit()) && val.len > 0 {
      return val.int()
    }
    // Safely check for floating-point numbers
    if val.contains(".") && val.replace(".", "").bytes().all(it.is_digit()) {
      return val.f64()
    }
    // Clean quotes off string literals
    if val.starts_with("\"") && val.ends_with("\"") && val.len >= 2 {
      return val[1..val.len - 1]
    }
    // Return Lisp identifier name as a string element
    return val
  }

  if token.typ == .lparen {
    unsafe { *index += 1 } // consume '('
    mut list := []json2.Any{}
    for unsafe { *index } < tokens.len && tokens[unsafe { *index }].typ != .rparen {
      list << parse_expression(tokens, mut index)
    }
    unsafe { *index += 1 } // consume ')'
    return list
  }

  return ""
}

//@ recursize_sexpressions_to_json(string) string
//@ recursize_sexpressions_to_json tokenizes and parses the Lisp string into JSON
fn recursize_sexpressions_to_json(lisp_code string) string {
  tokens := tokenize(lisp_code)
  mut index := 0
  ast := parse_expression(tokens, mut index)
  return ast.str()
}

fn main() {
  example := "
(
  (1 2 3 4 5 6 7 8 9 0)
  (def add (a b c e) (
    (return (+ a b c d))
  ))
  (setq result (add (1 1 2 3)))
  (printf(result))
)"
println(recursize_sexpressions_to_json(example))
}