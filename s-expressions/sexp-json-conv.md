
# Module:
- main

## Dependencies:
```v
// the simplest json lib in all v ecosystem.
import x.json2
```

## Functions:
```v
//PRIVATE

// tokenize(string) []Token
// tokenize splits the Lisp string into structural and literal tokens
fn tokenize(code string) []Token {
```
```v
//PRIVATE

// parse_expression([]Token, mut &int) json2.Any
// parse_expression recursively builds a json2.Any tree from tokens
fn parse_expression(tokens []Token, mut index &int) json2.Any {
```
```v
//PRIVATE

// recursize_sexpressions_to_json(string) string
// recursize_sexpressions_to_json tokenizes and parses the Lisp string into JSON
fn recursize_sexpressions_to_json(lisp_code string) string {
```
```v
//PRIVATE

fn main() {
```

## Structs:
```v
//PRIVATE

// toktypes.
// token struct.
struct Token {
```
