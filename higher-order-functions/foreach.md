
# Module:
- 

## Functions:
```v
//PUBLIC

fn (mut llist List[T]) append(item T) {
```
```v
//PUBLIC

fn (mut llist List[T]) push(item T) {
```
```v
//PUBLIC

fn (mut llist List[T]) pop() T {
```
```v
//PUBLIC

fn (llist List[T]) contains(item T) bool {
```
```v
//PUBLIC

fn (mut llist List[T]) zero() {
```
```v
//PUBLIC

fn (mut llist List[T]) convert_map[U](func fn(T) U) List[U] {
```
```v
//PUBLIC

fn (mut llist List[T]) foreach(func fn(T) ?T) {
```

## Structs:
```v
//PUBLIC

struct List[T] {
```
