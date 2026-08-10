package main

import "core:strings"
import "core:fmt"
import "core:unicode"

/*
  bm:
  - byte-machine: simple bytecode execution virtual machine.
  - stack based language argonomics.
  - registers are also avalable.
  - NO PARSER, NO AST.
  - low-level syntax.
*/

ez_err :: proc(line, col: int, message: string) {
  fmt.println("[", line, ":", col, "]: ", message)
}

/* Scanner.
*/
Scanner :: struct {
  ops: [dynamic]string,
}

scan_this :: proc(program: string) -> Scanner {
  scanner: Scanner
  code := strings.split(program, "", context.allocator)
  end  := len(code)
  ptr  := 0

  // positional and diagnostics info.
  line := 1
  col  := 0
  for {
    if ptr >= end {
      break
    }

    // x is current token.
    x := code[ptr]
    ptr += 1
    col += 1

    // Skip spaces entirely
    if x == " " {
      continue
    }

    if x == "\n" {
      line += 1
      col  = 0
      append(&scanner.ops, "\n")
    } else if unicode.is_alpha(rune(x[0])) {
      word := x
      for {
        if ptr >= end {
          break
        }

        w := code[ptr]
        // Peek ahead: only advance if it belongs to the alphabetic word
        if unicode.is_alpha(rune(w[0])) || w == "_" {
          word = strings.concatenate({word, w})
          ptr += 1
          col += 1
        } else {
          // Leave spaces, newlines, and symbols for the outer loop to handle
          break
        }
      }
      append(&scanner.ops, word)
    } else if x == "$" {
      word := x
      for {
        if ptr >= end {
          break
        }

        w := code[ptr]
        // Peek ahead: only advance if it belongs to the register name
        if unicode.is_alpha(rune(w[0])) || w == "_" {
          word = strings.concatenate({word, w})
          ptr += 1
          col += 1
        } else {
          break
        }
      }
      append(&scanner.ops, word)
    } else if unicode.is_number(rune(x[0])) {
      word := x
      dot  := false
      for {
        if ptr >= end {
          break
        }

        w := code[ptr]
        // Peek ahead: only advance if it belongs to the number
        if unicode.is_number(rune(w[0])) || w == "_" || (w == "." && !dot) {
          word = strings.concatenate({word, w})
          if w == "." {
            dot = true
          }
          ptr += 1
          col += 1
        } else {
          break
        }
      }
      append(&scanner.ops, word)
    } else if strings.contains_any(x, "+-*/") { // Added () to support your math string
      append(&scanner.ops, x)
    } else if x == "(" {
      word := x
      depth := 0
      for {
        if ptr >= end {
          break
        }

        w := code[ptr]
        word = strings.concatenate({word, w})
        ptr += 1
        col += 1
        if w == ")" && depth == 0 {
          break
        } else if w == ")" && depth > 0 {
          depth -= 1
        } else if w == "(" {
          depth += 1
        }
      }
      append(&scanner.ops, word)
    } else if x == "\"" { // Simple string literal scanning support
      word := x
      for {
        if ptr >= end {
          break
        }
        w := code[ptr]
        word = strings.concatenate({word, w})
        ptr += 1
        col += 1
        if w == "\"" {
          break
        }
      }
      append(&scanner.ops, word)
    } else {
      ez_err(line, col, "unsupported char.")
    }
  }
  return scanner
}

main :: proc() {
  program :=
`put (22 / 7) in $pi_value
put "Hello, Sailor" in $message
put $pi_value+2 in $whatever

push ($pi_value * 1234 / 534 + 2354 - 4324)

println $message
println $whatever`

  scanner := scan_this(program)
  fmt.println(scanner.ops)
}