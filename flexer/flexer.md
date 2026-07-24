
# Module:
- main

## Dependencies:
```v
import os
```

## Constants:
```v
//PRIVATE

const const_delims = "(){}[]<>,.?!:;=&|/\\@#$%^*'\" " // space also
```

## Functions:
```v
//PRIVATE

// flexer is a simple tokenizer for programming languages!
fn main() {
```
```v
//PUBLIC

fn (mut p Parser) expect(thing string) (bool, Tokendiag) {
```
```v
//PUBLIC

fn (mut p Parser) next() Tokendiag {
```
```v
//PRIVATE

// this function tokenizes every token, identifier, int literal, float literal, boolean, keyword, and these ( ) { } [ ] < > , . ? !
fn tokenize(line string) []string {
```
```v
//PRIVATE

fn whatever() {
```
```v
//PRIVATE

fn ignore_me() {
```

## Structs:
```v
//PRIVATE

// tok struct, with diagnostics info too!
struct Tokendiag {
```
```v
//PRIVATE

struct Parser {
```
