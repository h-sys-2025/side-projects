
# Module:
- main

## Dependencies:
```v
import bpe
import os
import rand
import json
import math
```

## Constants:
```v
//PRIVATE

// const of punctuation
const punct := ".,?!:;'-"
```

## Functions:
```v
//PRIVATE

fn main() {
```
```v
//PRIVATE

// tokenizer function
// this function decodes it! - this takes the BPE-ed data and does it's thing!
fn tokenizer(message string, translation_table map[string]string) string {
```
```v
//PRIVATE

// this function, turns punctuation into seperate tokens!
fn format_punctuation(tokens []string) []string {
```
```v
//PRIVATE

// this function removes tabs and extra white spaces!
fn format(data string) []string {
```
```v
//PRIVATE

// helper function: format and save to a file!
fn format_and_save(data string, formatted_file string) {
```
```v
//PRIVATE

// this function generates a markov-chain model with order (for markov chain)
//
// a little vibecoding never hurtes anyone: Generates Order-N Model using single string keys (e.g., "a|b|c")
//
fn build_model(tokens []string, order int) map[string]map[string]f64 {
```
```v
//PRIVATE

// for markov chain
// predict_n: Main prediction function with backoff and multi-token support
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
```
```v
//PRIVATE

// get_next_with_backoff: Variable order backoff
fn get_next_with_backoff(model map[string]map[string]f64, context string, temperature f64) string {
```
```v
//PRIVATE

// sample_with_temperature: Temperature sampling
fn sample_with_temperature(dist map[string]f64, temperature f64) string {
```
