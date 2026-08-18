
# Module:
- ccg

## Functions:
```v
//PUBLIC

fn c_program() C_dyn_ccg {
```
```v
//PUBLIC

fn (mut c_cg C_dyn_ccg) new_func(name string, ret_type string, args []string) {
```
```v
//PUBLIC

fn (mut c_cg C_dyn_ccg) func_add_stmt(name string, stmt string) {
```
```v
//PUBLIC

fn vardef(ret_type string, name string, value string) string {
```
```v
//PUBLIC

fn varval(name string) string {
```
```v
//PUBLIC

fn ret(thing string) string {
```
```v
//PUBLIC

fn func_call(name string, args []string) string {
```
```v
//PUBLIC

fn (mut c_cg C_dyn_ccg) print_func(name string) {
```

## Structs:
```v
//PRIVATE

struct Func {
```
```v
//PRIVATE

struct Sstruct {
```
```v
//PUBLIC

struct C_dyn_ccg {
```
