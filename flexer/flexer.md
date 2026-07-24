
# Module:
- main

## Dependencies:
```v
import os
```

## Constants:
```v
//PRIVATE

// testing vingle again
const something = "(){}[]<>,.?!:;=&|/\\@#$%^*'\" " // space also
//PRIVATE

const const_delims = something
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
