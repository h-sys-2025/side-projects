module ccg

//@ all functions will have this sig
struct Func {
  pub mut:
    name string
    args []string
    ret_type string
    body []string
}

//@ all structs, wither typedef or not will have this sig
struct Sstruct {
  pub mut:
    name string      // Sstruct
    is_typedef bool  // false
    items []string   // ["string name;", "bool is_typedef;", "string[] items;"]
}

//@ our dynamic-ly generated c progam
pub struct C_dyn_ccg {
  pub mut:
    functions map[string]Func
    structs   map[string]Sstruct
}

//@ initlizer for C_dyn_ccg
pub fn c_program() C_dyn_ccg {
  return C_dyn_ccg{}
}

//@ create new function
pub fn (mut c_cg C_dyn_ccg) new_func(name string, ret_type string, args []string) {
  c_cg.functions[name] = Func{
    name: name
    ret_type: ret_type
    args: args
  }
}

//@ add an stmt into an existign function
pub fn (mut c_cg C_dyn_ccg) func_add_stmt(name string, stmt string) {
  c_cg.functions[name].body << stmt
}

//@ declare a variable
pub fn vardef(ret_type string, name string, value string) string {
  return "${ret_type} ${name} = ${value};"
}

//@ call the value of a val
pub fn varval(name string) string {
  return "${name}"
}

//@ write return statement
pub fn ret(thing string) string {
  return "return ${thing};"
}

//@ call a function
pub fn func_call(name string, args []string) string {
  return "${name}(${args.join(",")});"
}

//@ print the function in console
pub fn (mut c_cg C_dyn_ccg) print_func(name string) {
  mut func := c_cg.functions[name]
  println("${func.ret_type} ${func.name}(${func.args.join(", ")}) {\n  ${func.body.join("\n  ")}\n}")}