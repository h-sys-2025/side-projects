module main

import os

enum TokenType {
  str
  number
  atom
  keyword
  special
  eof
}

struct Position {
  line int
  col  int
}

struct Token {
  toktype TokenType
  data    string
  pos     Position
}

struct Scanner {
pub mut:
  raw_program     string
  raw_pointer     int
  scanned_program []Token
  line            int = 1
  col             int = 1
}

fn (s Scanner) at_end() bool {
  return s.raw_pointer >= s.raw_program.len
}

fn (s Scanner) curr() string {
  if s.at_end() {
    return ''
  }
  return s.raw_program[s.raw_pointer].ascii_str()
}

fn (s Scanner) peek() string {
  if s.raw_pointer + 1 >= s.raw_program.len {
    return ''
  }
  return s.raw_program[s.raw_pointer + 1].ascii_str()
}

fn (mut s Scanner) advance() string {
  if s.at_end() {
    return ''
  }
  ch := s.raw_program[s.raw_pointer].ascii_str()
  s.raw_pointer++
  if ch == '\n' {
    s.line++
    s.col = 1
  } else {
    s.col++
  }
  return ch
}

fn (mut s Scanner) skip_whitespace() {
  for !s.at_end() {
    c := s.curr()
    if c == ' ' || c == '\t' || c == '\r' || c == '\n' {
      s.advance()
    } else {
      break
    }
  }
}

fn (mut s Scanner) parse_string() string {
  // opening " already consumed by caller
  mut content := ''
  for !s.at_end() && s.curr() != '"' {
    content += s.advance()
  }
  if s.curr() == '"' {
    s.advance() // closing "
  } else {
    eprintln('error: ${s.line}:${s.col}: unterminated string')
  }
  return content
}

fn (mut s Scanner) parse_atom() string {
  // leading : already consumed by caller
  mut content := ''
  for !s.at_end() && (is_alpha(s.curr()) || is_digit(s.curr()) || s.curr() == '_') {
    content += s.advance()
  }
  return content
}

fn (mut s Scanner) parse_number() string {
  mut content := ''
  mut has_dot := false
  for !s.at_end() {
    c := s.curr()
    if is_digit(c) {
      content += s.advance()
    } else if c == '.' && !has_dot {
      has_dot = true
      content += s.advance()
    } else {
      break
    }
  }
  return content
}

fn (mut s Scanner) parse_keyword() string {
  mut content := ''
  for !s.at_end() && (is_alpha(s.curr()) || is_digit(s.curr()) || s.curr() == '_') {
    content += s.advance()
  }
  return content
}

pub fn scan(program string) []Token {
  mut s := Scanner{
    raw_program: program
  }

  for !s.at_end() {
    s.skip_whitespace()
    if s.at_end() {
      break
    }

    start_line := s.line
    start_col := s.col
    c := s.curr()

    if c in ['(', ')', '[', ']', '{', '}', '<', '>'] {
      s.scanned_program << Token{
        toktype: .special
        data:    s.advance()
        pos:     Position{line: start_line, col: start_col}
      }
    } else if c in ['!', '@', '#', '$', '%', '^', '&', '*', '-', '+', '=', '/', '?', ',', '.', ';', "'", '\\', '|'] {
      s.scanned_program << Token{
        toktype: .special
        data:    s.advance()
        pos:     Position{line: start_line, col: start_col}
      }
    } else if c == '"' {
      s.advance() // consume opening "
      s.scanned_program << Token{
        toktype: .str
        data:    s.parse_string()
        pos:     Position{line: start_line, col: start_col}
      }
    } else if c == ':' {
      s.advance() // consume :
      s.scanned_program << Token{
        toktype: .atom
        data:    s.parse_atom()
        pos:     Position{line: start_line, col: start_col}
      }
    } else if is_digit(c) {
      s.scanned_program << Token{
        toktype: .number
        data:    s.parse_number()
        pos:     Position{line: start_line, col: start_col}
      }
    } else if is_alpha(c) {
      s.scanned_program << Token{
        toktype: .keyword
        data:    s.parse_keyword()
        pos:     Position{line: start_line, col: start_col}
      }
    } else {
      eprintln('error: ${s.line}:${s.col}: unknown character `${c}`')
      s.advance() // avoid infinite loop on bad input
    }
  }
  s.scanned_program << Token{
    toktype: .eof
    data: ""
    pos: Position{}
  }
  return s.scanned_program
}

fn is_alpha(ch string) bool {
  return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')
}

fn is_digit(ch string) bool {
  return ch >= '0' && ch <= '9'
}

fn main() {
  println(
    scan(
      os.read_file("./example.txt") or {
        eprintln("error reading file: ${err}")
        return
      }
    )
  )
  return
}