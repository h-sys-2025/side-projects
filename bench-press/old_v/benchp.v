module main

import os
import lua_support

fn main() {
  /*
	 BenchP (benchpress): Is a simple and easy to use program to benchmark my compilers(and other things too).

	 Design:
	 - `*Workflow:*`
	 i.   creates (.gitignore, benchfile.lua) files in `$dir = $cwd/.bench.ignore/~here~/`.
	 ii.  copies versions of compiler(or any other bin) to that $dir!.
	 iii. reads benchfile for configuration.
	 iv.  runs that configuration(in multipule processes/tasks, oh yeah!!!).
	 v.   reports time taken & reports failures.
	 - `*voila*`

	 */
	prg := os.args[0] or {return}
	cmd := os.args[1] or {""}
	tac_y := os.args[2] or {""}

	if cmd == "" {
		if run_benchp_conf(tac_y.to_lower() == "-y") or {
			eprintln("[!!] Failed to run default configuration, reason: ${err.msg()}")
			return
		} {
			println("[+] Ok...")
		}
	}

	return
}

fn get_benchfile_lua_path() string {
    return os.join_path(get_benchp_conf_dir_path(), "benchfile.lua")
}

fn get_default_lua_file_path() string {
    x1 := os.executable().split("/")
    return os.join_path(x1[0..x1.len-1].join("/"), "benchfile.lua")
}

const global_thing_prg_name = "bench_copy"

fn cwd() string {
  return os.getwd()
}

fn is_benchp_configured() bool {
  return ".bench.ignore" in os.ls(cwd()) or { return false }
}

fn get_benchp_conf_dir_path() string {
  return os.join_path(cwd(), ".bench.ignore/")
}

fn configure_benchp_here(tac_y bool) bool {
  if !is_benchp_configured() {
    create_benchp_dir_and_files(tac_y) or {
      eprintln("[!!] Failed to create benchp config dir!")
      return false
    }
  }
  return true
}

fn get_command_value_from_config_file(tac_y bool) string {
  target_kv := get_variables_from_lua_file(tac_y) or {
    eprintln("[!!] Could not get value of `cmd` from lua file, reason: ${err.msg()}")
    return ""
  }
  return target_kv["cmd"]
}

fn run_benchp_conf(tac_y bool) !bool {
  if !is_benchp_configured() { configure_benchp_here(tac_y) }
  cmd := get_command_value_from_config_file(tac_y)
  // now run it somehow.
  return true
}

fn get_variables_from_lua_file(tac_y bool) !map[string]string {
  file_path := get_benchfile_lua_path()
  if !os.exists(file_path) {
    eprintln("[!!] Config file ${file_path} does not exist, creating now...")
    if !configure_benchp_here(tac_y) {
      return error("failed to create configure dir and files.")
    }
  }
  variables := lua_support.parse_variables(file_path) or {
    eprintln("[!!] Could not read lua configuration file, reason: ${err.msg()}")
    return error("failed to read lua configuration file.")
  }

  target_keys := ["cmd"]
  mut target_kv := map[string]string{}
  for key in target_keys {
    if val := variables[key] {
      target_kv[key] = val
    } else {
      target_kv[key] = ""
    }
  }

  return target_kv
}

fn get_prg_name() string {
  return global_thing_prg_name
}

fn get_default_lua_conf() !string {
  lua_code := os.read_file(get_default_lua_file_path()) or {
    return error("failed to read config file.")
  }
  return lua_code.replace("$1", get_benchp_conf_dir_path()).replace("$2", get_prg_name())
}

fn create_benchp_dir_and_files(tac_y bool) !bool {
  mut u1_ok := tac_y
  if !tac_y {
    if os.input("[??] benchp configure dir does not exist ~~ do you want to create configure directory (${get_benchp_conf_dir_path()})? [Y/n]").to_lower()[0].str() == "y" {
      u1_ok = true
    }
  }

  if u1_ok {
    os.mkdir(get_benchp_conf_dir_path()) or {
      eprintln("[!!] Failed to create configure directory (${get_benchp_conf_dir_path()}), reason: ${err}")
      return false
    }
    lua_code := get_default_lua_conf() or {
      eprintln("[!!] failed to read default lua code, reason: ${err.msg()}")
      return error("# faield to read default file, copy it from here: ${get_benchfile_lua_path()}. you may re-try config creation process or check existance of benchfile.lua in provided path.")
    }
    files := {
      ".gitignore":    "*\n!.gitignore"
      "benchfile.lua": lua_code.str()
    }
    for file_name, content in files {
      file_path := os.join_path(get_benchp_conf_dir_path(), file_name)

      os.write_file(file_path, content) or {
        println("[!!] Failed to write to ${file_name}, reason: ${err}")
        continue
      }
      println("[+] Created file ${file_path}.")
    }
    return true
  }
  return false
}