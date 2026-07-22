
# Module:
- main

## Dependencies:
```v
import net
import time
import rand
import os
```

## Functions:
```v
//PRIVATE

fn main() {
```
```v
//PRIVATE

fn handle_connection(mut conn net.TcpConn, mut key_vault KV) {
```
```v
//PRIVATE

// key_manager function, manages the keys. Why not use global variables? i dont know how!
fn (mut key_vault KV) key_manager(key string, op string) (string, bool) {
```
```v
//PRIVATE

// genesis generates first key!
fn (mut key_vault KV) genesis() {
```

## Structs:
```v
//PRIVATE

// key_vault
struct KV {
```
