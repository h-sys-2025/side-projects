
# Module:
- main

## Dependencies:
```v
import os
```

## Constants:
```v
//PRIVATE

const CONST_DELIMS = "(){}[]<>,.?!:;=&|/\\@#$%^*'\" " // space also
```

## Functions:
```v
//PRIVATE

// flexer is a simple tokenizer for programming languages!
fn main() {
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
