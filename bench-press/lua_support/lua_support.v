/*
# to configure, only works in my system.
sudo ln -s /usr/include/lua5.4/lua.h /usr/include/lua.h
sudo ln -s /usr/include/lua5.4/lualib.h /usr/include/lualib.h
sudo ln -s /usr/include/lua5.4/lauxlib.h /usr/include/lauxlib.h
sudo ln -s /usr/include/lua5.4/luaconf.h /usr/include/luaconf.h
*/

module lua_support

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//@ These are some lua constants.
const lua_tstring  = 4 // tok_string
const lua_tnumber  = 3 // tok_number
const lua_tboolean = 1 // tok_boolean

@[typedef] // so we can use it as a `name`, other then `struct name`.
struct C.lua_State {}

// Few C APIs provided by lua package .h files.
fn C.luaL_newstate() &C.lua_State
fn C.luaL_openlibs(l &C.lua_State)
fn C.luaL_dofile(l &C.lua_State, filename &char) int
fn C.lua_close(l &C.lua_State)
fn C.lua_pushnil(l &C.lua_State)
fn C.lua_next(l &C.lua_State, index int) int
fn C.lua_type(l &C.lua_State, index int) int
fn C.lua_typename(l &C.lua_State, tp int) &char
fn C.lua_tostring(l &C.lua_State, index int) &char
fn C.lua_tonumber(l &C.lua_State, index int) f64
fn C.lua_toboolean(l &C.lua_State, index int) int
fn C.lua_pop(l &C.lua_State, n int)
fn C.lua_pushglobaltable(l &C.lua_State)

//@ this function `parse_variables(string) !map[string]string` reads a given Lua file (with path) and returns the map of (all public or local or whatever) global variables.
pub fn parse_variables(file_path string) !map[string]string {
  // To try to initialize lua state.
  l := C.luaL_newstate()
  if isnil(l) {
    return error('Failed to initialize Lua VM runtime.')
  }
  defer { C.lua_close(l) }

  // expand import/require things.
  C.luaL_openlibs(l)

  // Now run the file.
  if C.luaL_dofile(l, file_path.str) != 0 {
    err_msg := unsafe { byteptr(C.lua_tostring(l, -1)).vstring() }
    return error('Lua script execution error: ${err_msg}')
  }

  // the resultant thing.
  mut variables := map[string]string{}


  // the rest of code I am unsure, But i translated it form an example.
  C.lua_pushglobaltable(l) // this moves the global table onto the stack for faster access, since we are in a loop.
  global_table_index := -1
  C.lua_pushnil(l) // this will be the first key for loop.

  for C.lua_next(l, global_table_index) != 0 {
    // So lua has this thing, due to which, the locations are: k = -2, and v = -1
    key_type := C.lua_type(l, -2) // l, k

    if key_type == lua_tstring {
      var_name := unsafe { byteptr(C.lua_tostring(l, -2)).vstring() }

      // now to ignore the ignore things. like: _abc and more.
      if !var_name.starts_with('_') && var_name != 'package' && var_name != 'coroutine' {
        val_type := C.lua_type(l, -1)

        match val_type {
          lua_tstring {
            variables[var_name] = unsafe { byteptr(C.lua_tostring(l, -1)).vstring() }
          }
          lua_tnumber {
            val := C.lua_tonumber(l, -1)
            variables[var_name] = val.str()
          }
          lua_tboolean {
            val := C.lua_toboolean(l, -1) == 1
            variables[var_name] = val.str()
          }
          else {
            // This is a safe fallback: assign type name tag for functions, threads, or nested tables.
            tp_name := unsafe { byteptr(C.lua_typename(l, val_type)).vstring() }
            variables[var_name] = '[${tp_name}]'
          }
        }
      }
    }
    // now pop the value from the stack, but still keep the key on stack for next iteration (if any).
    C.lua_pop(l, 1)
  }

  return variables
}