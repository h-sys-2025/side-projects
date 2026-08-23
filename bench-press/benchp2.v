module main

import os
import time

fn main() {
  /*
    usage: %s <[-c candidates,for,benchmarking]> <[-x command]>
  */
  // read configuration file. and parse it!
  conf_file_path := os.args[1] or {"./.benchfile"}
  raw_content := os.read_file(conf_file_path) or {
    eprintln("{!!} failed to read benchfile, reason: ${err}")
    return
  }
  mut conf_cmds := []string{}
  for line in raw_content.split("\n") {
    lline := line.trim_space()
    if lline.starts_with("#") {
      continue
    }
    conf_cmds << lline
  }
  // run all candidates in seperate threads and calculate their time-taken.
  mut threads := []thread CommandResult{}

 	// now lets spawn some threads for each command.
 	for cmd in conf_cmds {
    println(":. starting \"${cmd}\"")
 	  threads << spawn run_command(cmd)
 	}
  results := threads.wait()

  // fmt-print and exit.
  for res in results {
  		mut status := "SUCC"
  		if res.exit_code != 0 {
      status = "FAIL"
  		}
  		println("command: ${res.cmd}")
  		println(" + status: ${status} (exit-code: ${res.exit_code})")
  		println(" + time-taken: ${res.duration_ms} ms\n")
 	}
 	return
}

//@ from old v1.
struct CommandResult {
  cmd          string
  exit_code    int
  duration_ms  i64
}

//@ this is a function to run a single thing(such as `sh` command) and then return some data.
fn run_command(cmd string) CommandResult {
  start := time.now()

  // to xecute the thing(command or process) using `sh -c` to run via `sh`.
  result := os.execute_opt("sh -c \"${cmd}\"") or {
   		eprintln("{!!} failed to execute \"${cmd}\"")
   		return CommandResult{
    			cmd: cmd
    			exit_code: -1
    			duration_ms: 0
   		}
  	}

  	end := time.now()
  	duration := end.unix_milli() - start.unix_milli() // we use milliseconds, so we can measure to the milliseconds.

  	return CommandResult{
   		cmd: cmd
   		exit_code: result.exit_code
   		duration_ms: i64(duration)
  	}
}