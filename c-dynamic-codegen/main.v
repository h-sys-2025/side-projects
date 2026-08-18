module main

import ccg {c_program, ret, varval, vardef, func_call}

//@ just the basic idea, will continue soon!
fn main() {

  mut hello_world := c_program()

  // main function.
  hello_world.new_func("main", "int", ["int argc", "char** argv"])
  hello_world.func_add_stmt("main",
    vardef("string", "message", "Hello, Sailor!")
  )
  hello_world.func_add_stmt("main",
    func_call("printf",[varval("message")])
  )
  hello_world.func_add_stmt("main", ret("0"))
  hello_world.print_func("main")
  return
}