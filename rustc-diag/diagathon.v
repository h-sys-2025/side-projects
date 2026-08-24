module main

import os

struct Col_info {
   start    int
   word_len int
   message  string
}

struct Err_info {
   file_path string
   line int
   cols []Col_info
}

fn main() {
   // Create the inner array first, or initialize it correctly
   mut cols := []Col_info{}
   cols <<		Col_info{
      start:    0
      word_len: 5
      message:  'spell strukt instead of `struct`.'
   }
   cols <<		Col_info{
      start:    8
      word_len: 7
      message:  'name it something related to rust.'
   }
   mut err_info := []Err_info{}
   err_info << Err_info{
      file_path: "./diagathon.v"
      line: 3
      cols: cols
   }

   println(fmt_error(err_info))
}

fn fmt_error(errors []Err_info) string {
   for line in errors {
      line_data := os.read_lines(line.file_path) or {
         eprintln("faield to read file ${line.file_path}")
         return "error while displaying errors."
      }
      println("${line.line:4} | ${line_data[line.line+1]}")
      // bias is: 4 + 1 + 1 + 1
      mut bias := 7
      mut errs_count := 0
      mut underline := "${" ".repeat(bias)}"
      for col in line.cols {
         underline = "${underline}${" ".repeat(col.start-7)}"
         underline = "${underline}${"^".repeat(col.word_len+1)}"
         bias += col.start + col.word_len+1
         errs_count += 1
      }
      println(underline)

      bias = 7
      mut mega_underline := "${" ".repeat(bias)}"
      mut space := true
      for under in underline.split("") {
         if under.str() == "^" && space == true{
            mega_underline = "${mega_underline}|"
            space = false
         } else {
            space = true
            mega_underline = "${mega_underline} "
         }
      }
      println(mega_underline)
   }
   return "displayed ${errors.len} errors."
}