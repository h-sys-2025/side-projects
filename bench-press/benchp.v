module main

import os
import time

struct CommandResult {
	out string
	code int
	time i64
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

	mut threads := []thread CommandResult{}

	for thing in things {
		// Skip non-executables explicitly
		if thing.contains(".lua") || thing.contains(".gitignore") {
			continue
		}

		file_name := os.join_path(cwd, ".bench.ignore", thing)
		cmd := base_cmd.replace("{thing}", file_name)

		// Debug: print the command being run
		// println("Running: ${cmd}")

		threads << spawn run_command(cmd)
	}

	results := threads.wait()

	for i, res in results {
		println("Task ${i + 1}:")
		println("  Output: ${res.out}")
		println("  Exit Code: ${res.code}")
		println("  Time: ${res.time} µs")
	}
}

fn run_command(cmd string) CommandResult {
	start := time.now()

	// Split by space, but filter out empty strings to avoid exec("")
	args := cmd.split(" ").filter(it.len > 0)

	// Fallback if args is empty
	if args.len == 0 {
		return CommandResult{
			out: "error: empty command"
			code: -1
			time: 0
		}
	}

	result := os.exec(args) or {
		return CommandResult{
			out: "exec failed: ${err}"
			code: -1
			time: 0
		}
	}

	end := time.now()
	duration_us := (end - start).microseconds()

	return CommandResult{
		out: result.output
		code: result.exit_code
		time: duration_us
	}
}