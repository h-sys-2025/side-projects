
# Module:
- main

## Dependencies:
```v
import encoding.base64
```

## Functions:
```v
//PRIVATE

fn (mut bs BsEnc) add_layer(name string, hashing_algo string) bool {
```
```v
//PRIVATE

fn (mut bs BsEnc) visualize() {
```
```v
//PRIVATE

fn (bs BsEnc) encrypt(data string, verbose bool) string {
```
```v
//PRIVATE

fn (bs BsEnc) decrypt(data string, verbose bool) string {
```
```v
//PRIVATE

fn main() {
```
```v
//PRIVATE

fn all_supported_hashing_algos() []string {
```
```v
//PRIVATE

fn encode(data string, algo string) string {
```
```v
//PRIVATE

fn decode(data string, algo string) string {
```

## Structs:
```v
//PRIVATE

struct Layer {
```
```v
//PUBLIC

struct BsEnc {
```
