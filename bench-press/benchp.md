
# Module:
- main

## Dependencies:
```v
import os
import lua_support
```

## Constants:
```v
//PRIVATE

const benchfile_lua_path = os.join_path(get_benchp_conf_dir_path(), 'benchfile.lua')
//PRIVATE

const default_lua_file_path = os.join_path(os.executable(), 'benchfile.lua')
//PRIVATE

const global_thing_prg_name = 'bench_copy'
```

## Functions:
```v
//PRIVATE

fn main() {
```
```v
//PRIVATE

fn cwd() string {
```
```v
//PRIVATE

fn is_benchp_configured() bool {
```
```v
//PRIVATE

fn get_benchp_conf_dir_path() string {
```
```v
//PRIVATE

fn configure_benchp_here(tac_y bool) bool {
```
```v
//PRIVATE

fn get_command_value_from_config_file(tac_y bool) string {
```
```v
//PRIVATE

fn run_benchp_conf(tac_y bool) bool {
```
```v
//PRIVATE

fn get_variables_from_lua_file(tac_y bool) !map[string]string {
```
```v
//PRIVATE

fn get_prg_name() string {
```
```v
//PRIVATE

fn get_default_lua_conf() !string {
```
```v
//PRIVATE

fn create_benchp_dir_and_files(tac_y bool) !bool {
```
