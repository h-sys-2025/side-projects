module main

import net
import time
import rand
import os

fn main() {
  mut server := net.listen_tcp(.ip, "localhost:8080") or {
    eprintln("fatal: Failed to start server on localhost:8080: ${err}")
    return
  }
  defer {
    server.close() or { eprintln("warning: error closing server: ${err}") }
  }

  println("Server listening on localhost:8080...")
  println(" help:
    wizz <PASSWORD> <COMMAND> --> OK(COMMAND)
    dead <PASSWORD>           --> OK(PASSWORD)
  ")
  mut key_vault := KV{}
  key_vault.genesis()

  for {
    mut conn := server.accept() or {
      eprintln("warning: Failed to accept connection: ${err}")
      continue
    }
    go handle_connection(mut conn, mut &key_vault)
	}
}

fn handle_connection(mut conn net.TcpConn, mut key_vault KV) {
  defer {
    conn.close() or { eprintln("warning: error closing connection: ${err}") }
  }

  mut buf := []u8{len: 1024}
  n := conn.read(mut buf) or {
    eprintln("warning: Failed to read from client: ${err}")
    return
  }

  if n < 1 {
    return
  }

  received := buf[..n].bytestr()
  println("Received: ${received}")
  mut response := ""
  cmd := received.str().to_lower().split(" ")
  if cmd[0] == "wizz" && cmd.len > 1 {
    password  := cmd[1]
    command   := cmd[2..]
    _, auth := key_vault.key_manager(password, "auth")
    if auth == true {
      // Send response
      fmt_cmd := command.join(" ").replace("\n","")
      res := os.execute("sh -c '${fmt_cmd}'")
      response = "${res.output}\n---\n${res.exit_code}\n"
    }
  } else if cmd[0] == "dead" && cmd.len > 0 {
    password  := cmd[1]
    key, auth  := key_vault.key_manager(password, "new")
    if auth == true {
      response = "ok cowboy: ${key}\n"
    }
  } else {
    // Send response
    response = "${time.now()}\n"
  }
  conn.write(response.bytes()) or {
    eprintln("warning: Failed to write to client: ${err}")
  }
}

//@ key_vault
struct KV {
  pub mut:
    keys map[string]u64
}

//@ key_manager function, manages the keys. Why not use global variables? i dont know how!
fn (mut key_vault KV) key_manager(key string, op string) (string, bool) {
  if op.str().to_lower() == "auth" {
    if key_vault.keys[key] != 0 && time.now().unix() < key_vault.keys[key] {
      return key, true
    } else {
      return key, false
    }
  } else if op.str().to_lower() == "new" {
    new_uuid := rand.uuid_v4()
    key_vault.keys[new_uuid] = u64(time.now().unix() + (60 * 60))
    return new_uuid, true
  }
  return "unreacheable!", false
}

//@ genesis generates first key!
fn (mut key_vault KV) genesis() {
  new_uuid := rand.uuid_v4()
  key_vault.keys[new_uuid] = u64(time.now().unix() + (60 * 60))
  println("genesis-uuid: ${new_uuid}")
}