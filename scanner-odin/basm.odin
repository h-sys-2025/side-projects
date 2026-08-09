package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode"

/* FileIO helpers.
*/
read_entire_file :: proc(file_path: string) -> (string, bool) {
    data, err := os.read_entire_file(file_path, context.allocator)
    if err != nil {
        return "", false
    }
    return string(data), true
}

/* Scanner implementation:
*/
TokType :: enum {
  STRING,     // "hello worlds"
  NUMBER,     // 3.14159
  REGISTER,   // $zaa
  OPERATION,  // add
  COMMA,      // , (for multipule registers, and items)
  DOT,        // . (for member access)
  COLON,      // :
  MACRO,      // %scope (starts with %)

  EOF,
  UNREACHEABLE,
  COMMENT,
  NEWLINE,
}

Position :: struct {
  /* file: string
   - file info? not now.
  */
  line: uint,
  col: uint
}

Token :: struct {
  /* Basic information.
  */
  type: TokType,
  value: string,

  /* Position info for debugging purposes.
  */
  position: Position,
}

Scanner :: struct {
  raw_prg: []string,
  prg_count: uint,
  raw_ptr: uint,

  /* For positional info.
  */
  line: uint,
  col:  uint,

  tokens: [dynamic]Token,
}

/* Scanning requirements:

  1. main scan loop. (scan_this(string))

  1.1: peek()
  1.2: advance()
  1.3: is_at_end()

  2. parse_string.
  3. parse_number.
  4. parse_operation. format `XXX YYY,ZZZ\n`
  5. parse_macro. format `%XXX YYY?\n` (?: optional)

  6. scanner_error.
*/

/* Main scanner loop.
*/
scan_this :: proc(program: string) -> Scanner {
  u1 := strings.split(program, "", context.allocator)
  scanner := Scanner{
    raw_prg = u1,
    prg_count = len(u1),
    raw_ptr = 0,
    line = 0,
    col  = 0,
    tokens = {},
  }

  for {
    this_tok := advance(&scanner)
    scanner.col += 1
    if this_tok == "eof" {
      if scanner.raw_ptr != scanner.prg_count {
        scanner_error(&scanner, "something went wrong! program ended, but still `raw_ptr` is not at end.")
      }
      break
    } else if this_tok == "\n" {
      append(&scanner.tokens, Token{
          type = .NEWLINE,
          value = "",
          position =  Position{
            line = scanner.line,
            col  = scanner.col
          }
        })
      scanner.line += 1
      scanner.col  = 1
    } else if this_tok == "." || this_tok == "," {
      if this_tok == "." {
        append(&scanner.tokens, Token{
          type = .DOT,
          value = ".",
          position =  Position{
            line = scanner.line,
            col  = scanner.col
          }
        })
      } else {
        append(&scanner.tokens, Token{
        type = .COMMA,
        value = ".",
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
      }
    } else if this_tok == "%" {
      macro_name := this_tok
      for {
        peek_ := peek(&scanner)
        if unicode.is_alpha(rune(peek_[0])) || rune(peek_[0]) == rune("_"[0]) {
          macro_name = strings.concatenate({macro_name, advance(&scanner)})
          continue
        }
        break
      }
      append(&scanner.tokens, Token{
        type = .MACRO,
        value = macro_name,
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
    } else if this_tok == ";" { // ignore comments.
      comment := this_tok
      for {
        peek_ := peek(&scanner)
        if peek_ == "\n" {
          break
        }
        comment = strings.concatenate({comment, advance(&scanner)})
      }
      append(&scanner.tokens, Token{
        type = .COMMENT,
        value = comment,
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
    } else if this_tok == "'" { // parse operations
      string_data := ""
      for {
        peek_ := peek(&scanner)

        if peek_ == "eof" || peek_ == "\n" {
          scanner_error(&scanner, "unterminated string.")
          break
        }

        if peek_ != "'" {
          string_data = strings.concatenate({string_data, advance(&scanner)})
          continue
        } else {
          advance(&scanner)
          break
        }

        break
      }
      append(&scanner.tokens, Token{
        type = .STRING,
        value = string_data,
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
    } else if unicode.is_alpha(rune(this_tok[0])) { // parse operations
      operation := this_tok
      for {
        peek_ := peek(&scanner)
        if unicode.is_alpha(rune(peek_[0])) {
          operation = strings.concatenate({operation, advance(&scanner)})
          continue
        }
        break
      }
      append(&scanner.tokens, Token{
        type = .OPERATION,
        value = operation,
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
    }
  }

  return scanner
}

/* Scanner utils.
*/
is_at_end :: proc(scanner: ^Scanner) -> bool {
  return scanner.raw_ptr >= scanner.prg_count
}

peek :: proc(scanner: ^Scanner) -> string {
  if !is_at_end(scanner) {
    return scanner.raw_prg[scanner.raw_ptr] // Fixed: peek at the current raw pointer index
  }

  return "eof"
}

advance :: proc(scanner: ^Scanner) -> string {
  if is_at_end(scanner) do return "eof"

  res := scanner.raw_prg[scanner.raw_ptr]
  scanner.raw_ptr += 1
  return res
}

this :: proc(scanner: ^Scanner) -> string {
  if !is_at_end(scanner) {
    return scanner.raw_prg[scanner.raw_ptr]
  }
  return "eof"
}

/* For error related info.
*/
scanner_error_ :: struct {
  /* Positional info.
  */
  line: uint,
  col : uint,

  message: string,
}

/* Global list of errors. since scanner_error(^Scanner, string) does not halt the program on a single error.
*/
scanner_errors: [dynamic]scanner_error_

scanner_error :: proc(scanner_inst: ^Scanner, message: string) {
  /* Diagnostics and positional info.
  */
  line := scanner_inst.line
  col  := scanner_inst.col
  fmt.println("[",line,":",col,"]: ", message)
  append(&scanner_errors, scanner_error_{
    line = line,
    col  = col,
    message = message,
  })
  if len(scanner_errors) > 11 {
    append(&scanner_errors, scanner_error_{
      line = 0,
      col  = 0,
      message = "to many scanner errors, fix them first.",
    })
    os.exit(1)
  }
}

/* Main.
*/
main :: proc() {
  /*
  if len(os.args) <= 1 {
      fmt.println(os.args[0], ": Usage: <file.basm>")
      return
  }

  file_path := os.args[1]
  contents, ok := read_entire_file(file_path)
  if !ok {
      fmt.println(os.args[0], ": Could not read file:", file_path)
      return
  }

  if contents == "" {
      fmt.println(os.args[0], ": file:", file_path, "is empty.")
      return
  }

  */

  contents := `
%entry main
%scope
  ; call fmt.println(string)
  push 'Hello, Sailor!'
  call fmt.println

  ; return with exit code 0: os.exit(0)
  push 0
  call os.exit ; program halts automatickly.
%end
  `

  scanned_prg := scan_this(contents)
  // fmt.println(scanned_prg.raw_prg)
  for x in scanned_prg.tokens {
    fmt.println(x.type, ": ", x.value)
  }

  /* Delete allocated globals.
  */
  delete(scanner_errors)
}