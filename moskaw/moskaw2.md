
# Module:
- main

## Dependencies:
```v
import os
import math
import rand
```

## Constants:
```v
// fmt_corpus: Corpus cleaning
const prohibited_chars := "[]—"
```

## Functions:
```v
fn main() {
```
```v
// predict_n: Main prediction function with backoff and multi-token support
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
```
```v
// get_next_with_backoff: Variable order backoff
fn get_next_with_backoff(model map[string]map[string]f64, context string, temperature f64) string {
```
```v
// sample_with_temperature: Temperature sampling
fn sample_with_temperature(dist map[string]f64, temperature f64) string {
```
```v
// build_model: Variable length context and prediction up to `order`
fn build_model(tokens []string, order int) map[string]map[string]f64 {
```
```v
// tokenize: Much better tokenizer (the real fix)
fn tokenize(data string) []string {
```
```v
// get_data
fn get_data(file_path string) string {
```
```v
fn fmt_corpus(file_path string) {
```
```v
fn min(a int, b int) int {
```