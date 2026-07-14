
# Module:
- main

## Dependencies:
```v
import bpe
import os
```

## Constants:
```v
// const of punctuation
const punct := ".,?!:;'-"
```

## Functions:
```v
fn main() {
```
```v
// tokenizer function
// this function decodes it! - this takes the BPE-ed data and does it's thing!
fn tokenizer(message string, translation_table map[string]string) string {
```
```v
// this function, turns punctuation into seperate tokens!
fn format_punctuation(tokens []string) []string {
```
```v
// this function removes tabs and extra white spaces!
fn format(data string) []string {
```
```v
// helper function: format and save to a file!
fn format_and_save(data string, formatted_file string) {
```
