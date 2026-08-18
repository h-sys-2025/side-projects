
# Module:
- ccg

## Functions:
```v
//PUBLIC

// initlizer for C_dyn_ccg
fn c_program() C_dyn_ccg {
```
```v
//PUBLIC

// create new function
fn (mut c_cg C_dyn_ccg) new_func(name string, ret_type string, args []string) {
```
```v
//PUBLIC

// add an stmt into an existign function
fn (mut c_cg C_dyn_ccg) func_add_stmt(name string, stmt string) {
```
```v
//PUBLIC

// declare a variable
fn vardef(ret_type string, name string, value string) string {
```
```v
//PUBLIC

// call the value of a val
fn varval(name string) string {
```
```v
//PUBLIC

// write return statement
fn ret(thing string) string {
```
```v
//PUBLIC

// call a function
fn func_call(name string, args []string) string {
```
```v
//PUBLIC

// print the function in console
fn (mut c_cg C_dyn_ccg) print_func(name string) {
```

## Structs:
```v
//PRIVATE

// all functions will have this sig
struct Func {
```
```v
//PRIVATE

// all structs, wither typedef or not will have this sig
struct Sstruct {
```
```v
//PUBLIC

// our dynamic-ly generated c progam
struct C_dyn_ccg {
```
