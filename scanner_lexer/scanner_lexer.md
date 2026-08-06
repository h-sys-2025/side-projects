
# Module:
- lox_scanner

## Functions:
```v
//PRIVATE

fn (s Scanner) at_end() bool {
```
```v
//PRIVATE

fn (s Scanner) curr() string {
```
```v
//PRIVATE

fn (s Scanner) peek() string {
```
```v
//PRIVATE

fn (mut s Scanner) advance() string {
```
```v
//PRIVATE

fn (mut s Scanner) skip_whitespace() {
```
```v
//PRIVATE

fn (mut s Scanner) parse_string() string {
```
```v
//PRIVATE

fn (mut s Scanner) parse_atom() string {
```
```v
//PRIVATE

fn (mut s Scanner) parse_number() string {
```
```v
//PRIVATE

fn (mut s Scanner) parse_keyword() string {
```
```v
//PUBLIC

fn scan(program string) []Token {
```
```v
//PRIVATE

fn is_alpha(ch string) bool {
```
```v
//PRIVATE

fn is_digit(ch string) bool {
```

## Structs:
```v
//PRIVATE

struct Position {
```
```v
//PRIVATE

struct Token {
```
```v
//PRIVATE

struct Scanner {
```
