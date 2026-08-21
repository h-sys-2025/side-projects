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
  LABEL,      // main:

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
      // if a operation ends with : then it is a label definition.
      if peek(&scanner) == ":" {
        append(&scanner.tokens, Token{
          type = .LABEL,
          value = strings.concatenate({operation,advance(&scanner)}),
          position =  Position{
            line = scanner.line,
            col  = scanner.col
          }
        })
      } else {
        append(&scanner.tokens, Token{
          type = .OPERATION,
          value = operation,
          position =  Position{
            line = scanner.line,
            col  = scanner.col
          }
        })
      }
    } else if this_tok == "$" { // parse operations
      register := ""
      for {
        peek_ := peek(&scanner)
        if unicode.is_alpha(rune(peek_[0])) {
          register = strings.concatenate({register, advance(&scanner)})
          continue
        }
        break
      }
      append(&scanner.tokens, Token{
        type = .REGISTER,
        value = register,
        position =  Position{
          line = scanner.line,
          col  = scanner.col
        }
      })
    } else if unicode.is_number(rune(this_tok[0])) { // parse numbers
      number := fmt.tprint(this_tok)
      dot := false
      for {
        peek_ := peek(&scanner)
        if unicode.is_number(rune(peek_[0])) || (peek_ == "." && dot != true) {
          number = strings.concatenate({number, advance(&scanner)})
          if peek_ == "." {
            dot = true
          }
          continue
        }
        break
      }
      append(&scanner.tokens, Token{
        type = .NUMBER,
        value = number,
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
main:
  ; call fmt.println(string)
  push 'Hello, Sailor!'
  call fmt.println

  push 34
  push 35
  call add
  call fmt.println

  push 34
  push 35
  call sub
  call fmt.println

  push 34
  push 35
  call mult
  call fmt.println

  push 34
  push 35
  call div
  call fmt.println

  mov 123, $a
  push $a
  mov $a, $zzz
  dup
  call fmt.println

  mov 11, $qwerty
  loop:
    dec $qwerty
    push $qwerty
    dup
    call fmt.println

    pop $qwerty
    mov 0, $aaaaaaa
    jg  $qwerty $aaaaaaa loop

  push $zzz
  dup
  call fmt.println

  mov 0, $zzz
  mov 0, $a

  ; return with exit code 0: os.exit(0)
  halt
  `

  /*
  ; future
  mov 0, $x
  loop:
    push 1
    push $x
    add
    pop $z
    mov $z, $x
    push $x
    call fmt.println
    goto loop
  */

  // scanning.
  scanned_prg := scan_this(contents)
  // test
  /*
    for x in scanned_prg.tokens {
      fmt.println(x.type, " --> ", x.value)
    }
  */

  // evaluating it directly. (easy-mode)
  // fmt.println(scanned_prg.raw_prg)
  labels := make(map[string]uint)
  stack  : [dynamic]string // la-stack.
  reg    := make(map[string]string)

  raw_ptr :uint= 0
  for {
    if raw_ptr >= len(scanned_prg.tokens) {
      break
    }
    x := scanned_prg.tokens[raw_ptr]
    // fmt.println(x.type, " --> ", x.value)
    if x.type == .NEWLINE {
      // continue
    } else if x.type == .MACRO {
      // how to define macros? lets just forget about them for now.
    } else if x.type == .LABEL {
      name := x.value
      if len(name) > 0 && name[len(name)-1] == ':' {
          name = name[:len(name)-1]
      }
      labels[name] = uint(raw_ptr) // token index of the LABEL token
      // fmt.println("defined:",name," at: ",raw_ptr)
    } else if x.type == .OPERATION {
      // now we handle all operations, push, pop, add, sub, mult, div, jmp, cmp and moreeeeee.......
      if x.value == "halt" {
        // os.exit(0)
        break
      } else if x.value == "cmp" {
        a_str := pop(&stack)
        b_str := pop(&stack)

        a, ok1 := strconv.parse_int(a_str, 10)
        b, ok2 := strconv.parse_int(b_str, 10)

        if ok1 && ok2 {
          ww := 0
          if a > b {
            ww = 1
          } else if a < b {
            ww = -1
          } else {
            ww = 0
          }
          result_str := fmt.aprintf("%d", ww)
          append(&stack, result_str)
        } else {
          fmt.println("runtime error: failed to parse stack values to integers.")
        }
      } else if x.value == "jmp" {
        raw_ptr += 1
        y := scanned_prg.tokens[raw_ptr]
        if y.type == .OPERATION {
          raw_ptr = labels[y.value]
        } else {
          fmt.println("runtime error: jmp expects a label name")
        }
      } else if x.value == "jg" {
        raw_ptr += 1
        y := scanned_prg.tokens[raw_ptr]
        if y.type == .REGISTER {
          raw_ptr += 1
          z := scanned_prg.tokens[raw_ptr]
          if z.type == .REGISTER {
            raw_ptr += 1
            a, ok1 := strconv.parse_int(reg[y.value], 10)
            b, ok2 := strconv.parse_int(reg[z.value], 10);
            if a > b {
              raw_ptr += 1
              ww := scanned_prg.tokens[raw_ptr]
              if (ww.type == .OPERATION) {
                raw_ptr = labels[z.value]
              } else {
                fmt.println("runtime error: usage: jg $a $b label")
              }
            }
          } else {
            fmt.println("@1runtime error: jg expects a register, register, label name")
          }
        } else {
          fmt.println("@runtime error: jg expects a register, register, label name")
        }
      } else if x.value == "push" {
        for {
          raw_ptr += 1
          y := scanned_prg.tokens[raw_ptr]
          if y.type == .NEWLINE {
            break
          } else if y.type == .REGISTER {
            append(&stack, reg[y.value])
          } else if y.type == .STRING || y.type == .NUMBER {
            append(&stack, y.value)
          } else {
            fmt.println("runtime error: expected either $register or 'string' or number. got: ", y.type)
            break
          }
        }
      } else if x.value == "mov" {
        raw_ptr += 1
        y := scanned_prg.tokens[raw_ptr]
        if y.type == .STRING || y.type == .NUMBER {
          raw_ptr += 1
          z := scanned_prg.tokens[raw_ptr]
          if z.type == .COMMA {
            raw_ptr += 1
            w := scanned_prg.tokens[raw_ptr]
            if w.type == .REGISTER {
              reg[w.value] = y.value
            } else {
              fmt.println("expected a register, got:", w.type)
            }
          } else {
            fmt.println("expected a comma after value to mov.")
          }
        } else if y.type == .REGISTER {
          raw_ptr += 1
          z := scanned_prg.tokens[raw_ptr]
          if z.type == .COMMA {
            raw_ptr += 1
            w := scanned_prg.tokens[raw_ptr]
            if w.type == .REGISTER {
              reg[w.value] = reg[y.value]
            } else {
              fmt.println("expected a register, got:", w.type)
            }
          } else {
            fmt.println("expected a comma after value to mov.")
          }
        } else {
          fmt.println("only support $registers, strings and number for now, considering this is a toy interpreter.")
        }
      } else if x.value == "pop" {
        for {
          // keep pushing values o stak untill NEWLINE is encounteried.
          raw_ptr += 1
          y := scanned_prg.tokens[raw_ptr]
          if y.type == .NEWLINE {
            break
          } else if y.type == .REGISTER {
            thing := pop(&stack) // pop from stack (with no safety features btw)
            reg[y.value] = thing // assign to reg
          } else {
            fmt.println("runtime error: expected a $register, got: ", y.type)
            break
          }
        }
      } else if x.value == "dup" {
        x := pop(&stack)
        append(&stack, x)
        append(&stack, x)
      } else if x.value == "call" {
        // keep pushing values o stak untill NEWLINE is encounteried.
        raw_ptr += 1
        y := scanned_prg.tokens[raw_ptr]
        if y.type == .OPERATION {
          if y.value == "add" {
            b_str := pop(&stack)
            a_str := pop(&stack)

            b, ok2 := strconv.parse_int(b_str, 10)
            a, ok1 := strconv.parse_int(a_str, 10)

            if ok1 && ok2 {
              result_str := fmt.aprintf("%d", a + b)
              append(&stack, result_str)
            } else {
              fmt.println("runtime error: failed to parse stack values to integers.")
            }
          } else if y.value == "sub" {
            b_str := pop(&stack)
            a_str := pop(&stack)

            b, ok2 := strconv.parse_int(b_str, 10)
            a, ok1 := strconv.parse_int(a_str, 10)

            if ok1 && ok2 {
              result_str := fmt.aprintf("%d", a - b)
              append(&stack, result_str)
            } else {
              fmt.println("runtime error: failed to parse stack values to integers.")
            }
          } else if y.value == "mult" {
            b_str := pop(&stack)
            a_str := pop(&stack)

            b, ok2 := strconv.parse_int(b_str, 10)
            a, ok1 := strconv.parse_int(a_str, 10)

            if ok1 && ok2 {
              result_str := fmt.aprintf("%d", a * b)
              append(&stack, result_str)
            } else {
              fmt.println("runtime error: failed to parse stack values to integers.")
            }
          } else if y.value == "div" {
            b_str := pop(&stack)
            a_str := pop(&stack)

            b, ok2 := strconv.parse_int(b_str, 10)
            a, ok1 := strconv.parse_int(a_str, 10)

            if ok1 && ok2 {
              result_str := fmt.aprintf("%d", a / b)
              append(&stack, result_str)
            } else {
              fmt.println("runtime error: failed to parse stack values to integers.")
            }
          }
        } else if x.value == "dec" {
          raw_ptr += 1
          y := scanned_prg.tokens[raw_ptr]
          if y.type == .REGISTER {
              val, ok := strconv.parse_int(reg[y.value], 10)
              if ok {
                  reg[y.value] = fmt.aprintf("%d", val - 1)
              } else {
                  fmt.println("runtime error: failed to parse register value as integer")
              }
          } else {
              fmt.println("only support $registers.")
          }
        } else if x.value == "inc" {
          raw_ptr += 1
          y := scanned_prg.tokens[raw_ptr]
          if y.type == .REGISTER {
              val, ok := strconv.parse_int(reg[y.value], 10)
              if ok {
                  reg[y.value] = fmt.aprintf("%d", val + 1)
              } else {
                  fmt.println("runtime error: failed to parse register value as integer")
              }
          } else {
              fmt.println("only support $registers.")
          }
        } else {
            func_name := ""
            for {
                raw_ptr += 1
                z := scanned_prg.tokens[raw_ptr]
                if (z.type == .NEWLINE) {break}
                else {
                    func_name = strings.concatenate({func_name, z.value})
                }
            }

            if (func_name == "fmt.println") {
                fmt.println(pop(&stack))
            }
            else {
                fmt.println("runtime error: expected a function_name (which is of type operation), got: ", y.type)
                break
            }
        }
      }
    }
    raw_ptr += 1
  }

  fmt.println("---\nstack: ", stack)
  fmt.println("---\nregisters: ", reg)
  fmt.println("---\nlabels", labels)

  /* Delete allocated globals.
  */
  delete(scanner_errors)
  // delete(labels)
}