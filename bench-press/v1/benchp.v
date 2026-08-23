module main

import os
import time

struct Cmd_res_thing {
  out string
  code int
  ttime i64
}

fn main() {
  cwd := os.getwd()
  bench_file_path := os.join_path(cwd, ".benchfile")
  things_dir_path := os.join_path(cwd, ".bench.ignore")
  prg := os.args[0]

  content := os.read_file(bench_file_path) or {
    eprintln("${prg}: failed to read benchfile, reason: ${err}, creating it now...")
    os.write_file(bench_file_path, "#Hello, Sailor!\n{thing}") or {
      eprintln("${prg}: failed to create benchfile, reason: ${err}, exiting...")
      return
    }
    os.read_file(bench_file_path)!
  }

  mut base_cmd := ""
  for line in content.split("\n") {
    trimmed := line.trim_space()
    if trimmed.len == 0 || trimmed.starts_with("#") {
      continue
    }
    // Append with a space only if base_cmd is not empty
    if base_cmd.len > 0 {
      base_cmd += " " + trimmed
    } else {
      base_cmd = trimmed
    }
  }

  things := os.ls(things_dir_path) or { []string{} }
  if things.len < 1 {
    println("no things in ${things_dir_path}")
    return
  }

  mut threads := []thread Cmd_res_thing{}

  for thing in things {
    if thing.contains(".lua") || thing.contains(".gitignore") {
      continue
    }

    file_name := os.join_path(cwd, ".bench.ignore", thing)
    cmd := base_cmd.replace("{thing}", file_name)
    threads << spawn run_this_command_please(cmd)
  }

  results := threads.wait() // I am unsure abotu a better way to do this.

  for i, res in results {
    println("Work #${i + 1}:")
    println("  output: ${res.out}")
    println("  exit-code: ${res.code}")
    println("  time-taken: ${res.ttime} (micro seconds) | ${f64(res.ttime/1000/1000)} seconds")
  }
}

fn run_this_command_please(cmd string) Cmd_res_thing {
  args := cmd.split(" ").filter(it.len > 0)
  if args.len == 0 {
    return Cmd_res_thing{
      out: "error: empty command"
      code: -1
      ttime: 0
    }
  }

  start := time.now()
  result := os.exec(args)
  duration_us := (time.now() - start).microseconds()

  return Cmd_res_thing{
    out:  result.output
    code: result.exit_code
    ttime: duration_us
  }
}