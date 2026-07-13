module main

//@ la-compare, voila!
fn compare[T](a T, b T) int {
    if a < b { // as easy as it an be!!
        return -1
    }
    if a > b {
        return 1
    }
    return 0
}

//@ generics in v are awsome!
// but on the go, i found about the harsh reality!
// v generates 4k lines of boilerplate!!!!
// just try DCE brah!
//@ for more info on generics, take a look: ./higher-order-functions/*here*
//@
//@ someday, I will try to make REAL generics in C, someday?!.
fn main() {
    println(compare(2,55))
    return
}