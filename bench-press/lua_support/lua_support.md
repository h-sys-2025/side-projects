
# Module:
- lua_support

## Constants:
```v
//PRIVATE

// These are some lua constants.
const lua_tstring  = 4 // tok_string
//PRIVATE

const lua_tnumber  = 3 // tok_number
//PRIVATE

const lua_tboolean = 1 // tok_boolean
```

## Functions:
```v
//PRIVATE

fn C.luaL_newstate() &C.lua_State
```
```v
//PRIVATE

fn C.luaL_openlibs(l &C.lua_State)
```
```v
//PRIVATE

fn C.luaL_dofile(l &C.lua_State, filename &char) int
```
```v
//PRIVATE

fn C.lua_close(l &C.lua_State)
```
```v
//PRIVATE

fn C.lua_pushnil(l &C.lua_State)
```
```v
//PRIVATE

fn C.lua_next(l &C.lua_State, index int) int
```
```v
//PRIVATE

fn C.lua_type(l &C.lua_State, index int) int
```
```v
//PRIVATE

fn C.lua_typename(l &C.lua_State, tp int) &char
```
```v
//PRIVATE

fn C.lua_tostring(l &C.lua_State, index int) &char
```
```v
//PRIVATE

fn C.lua_tonumber(l &C.lua_State, index int) f64
```
```v
//PRIVATE

fn C.lua_toboolean(l &C.lua_State, index int) int
```
```v
//PRIVATE

fn C.lua_pop(l &C.lua_State, n int)
```
```v
//PRIVATE

fn C.lua_pushglobaltable(l &C.lua_State)
```
```v
//PUBLIC

// this function `parse_variables(string) !map[string]string` reads a given Lua file (with path) and returns the map of (all public or local or whatever) global variables.
fn parse_variables(file_path string) !map[string]string {
```

## Structs:
```v
//PRIVATE

struct C.lua_State {}
```
