
# Module:
- main

## Dependencies:
```v
import encoding.base64
```

## Functions:
```v
fn (mut bs BsEnc) add_layer(name string, hashing_algo string) bool {
```
```v
fn (mut bs BsEnc) visualize() {
```
```v
fn (bs BsEnc) encrypt(data string, verbose bool) string {
```
```v
fn (bs BsEnc) decrypt(data string, verbose bool) string {
```
```v
fn main() {
```
```v
fn all_supported_hashing_algos() []string {
```
```v
fn encode(data string, algo string) string {
```
```v
fn decode(data string, algo string) string {
```

## Structs:
```v
struct Layer {
```
