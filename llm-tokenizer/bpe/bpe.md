
# Module:
- bpe

## Constants:
```v
//PUBLIC

// const of replacing space.
const space_replacer := "%%"
//PUBLIC

// const of replacing new-line.
const newline_replacer := "%$"
```

## Functions:
```v
//PRIVATE

fn split_2(text string) []string {
```
```v
//PUBLIC

// this function decodes it!
fn please_decode_this(message string, translation_table map[string]string) string {
```
```v
//PUBLIC

// this functio encodes bpe
fn please_encode_this(message string) (string, map[string]string) {
```
