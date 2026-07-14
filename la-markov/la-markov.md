
# Module:
- main

## Dependencies:
```v
import os
import rand
```

## Constants:
```v
// const of tokenizer-delims
const tokenizer_delims := ".,::'\"(){} "
// const of anti-delim for tokenizer
const anti_delim := "|"
// constant of prohibited chars!
const prohibited_chars := "[]—"
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
//
// a little vibecoding never hurtes anyone: Generates Order-N Model using single string keys (e.g., "a|b|c")
//
fn gen_model_n(corpus string, order int) map[string]map[string]f64 {
```
```v
// Helper: selects a random key from a map[string]f64 based on weights (probabilities)
fn pick_weighted(next_map map[string]f64) string {
```
```v
// the main thing, the mighty prediction function! it does the job!!!
fn predictoin(model map[string]map[string]f64, prompt string, n int) []string {
```
```v
//
// Predicts using single string keys. No slice history management needed inside loop.
//
fn predict_n(model map[string]map[string]f64, prompt string, n int, order int) []string {
```
```v
// util func: this function tokenizes every word in provided corpus. - it does some long repititive tasks!
fn tokenize(corpus string) string {
```
```v
// util func: count number of times word is occurred!
fn count_tokens_occurrences(tokens []string) map[string]int {
```
```v
// util func: sorts a map[string]int
fn sort_map(data map[string]int) map[string]int {
```
```v
// this is a temp function!
fn fmt_corpus(file_path string) {
```

## Structs:
```v
// useless struct, v does not allow sorting???!!!!!
struct KV {
```
