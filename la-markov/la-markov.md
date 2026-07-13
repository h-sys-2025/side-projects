
# Module:
- main

## Dependencies:
```v
import os
```

## Constants:
```v
// constant of prohibited chars!
const prohibited_chars := "[]"
```

## Functions:
```v
fn main() {
```
```v
//
// This function reads the corpus file
//
fn get_data(file_path string) string {
```
```v
//
// This function takes in curpos data as input and generates a json based markov chain model!
//
fn gen_model(corpus string) map[string]map[string]f64 {
```
```v
// this is a temp function!
fn fmt_corpus(file_path string) {
```
