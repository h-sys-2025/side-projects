module main

pub struct List[T] {
    pub mut:
        items []T
        len i64
}

pub fn (mut llist List[T]) append(item T) {
    llist.items << item
    llist.len = llist.items.len
}

pub fn (mut llist List[T]) push(item T) {
    llist.append(item)
}

pub fn (mut llist List[T]) pop() T {
    llist.len -= 1
    return llist.items.pop()
}

pub fn (llist List[T]) contains(item T) bool {
    return item in llist.items
}

pub fn (mut llist List[T]) zero() {
    llist.items = []T{}
    llist.len = 0
}

pub fn (mut llist List[T]) map[U](func fn(T) U) List[U] {
    mut list_u := List[U]{}
    burner := $zero(U)
    for x in 0..llist.items.len {
        item_before := llist.items[x]
        item_after := func(item_before)
        if typeof(item_after).name == typeof(burner).name {
            list_u.items << item_after
        }
    }

    return list_u
}

pub fn (mut llist List[T]) filter(func fn(T, List[T]) bool) {
    mut list_filtered := List[T]{}
    for x in 0..llist.items.len {
        if func(llist.items[x], llist) == true {
          list_filtered.items << llist.items[x]
        }
    }

    llist.items = list_filtered.items
}

pub fn (mut llist List[T]) foreach(func fn(T) ?T) {
    for x in 0..llist.items.len {
        item_before := llist.items[x]
        item_after := func(item_before)
        if item_after != none {
            llist.items[x] = item_after
        }
    }
}

//@ main function (testing mingle again, ignore this!!)
fn main() {
  // generics are awsome
  mut names := List[string]{}

  names.push("hamza")
  names.push("someone")
  names.push("noone")

  println("pop: ${names.pop()}")
  println("len: ${names.len}")
  println("contains \"hamza\": ${names.contains("hamza")}")
  println("contains \"qwerty\": ${names.contains("qwerty")}")

  // the big thing!
  // higher-order-functions!
  names.foreach(fn(x string) ?string {
      return "${x}1111"
  })

  // now lets try to convert!
  mut nnames := names.map[[]string](fn(x string) []string {
      return x.split("")
  })

  nnames.foreach(fn(x []string) ?[]string {
      println("converted to []string: ${x} it was originally \"${x.join("")}\"")
      return none
  })

  mut primes := List[u64]{}
  for x in 1..250 {
    primes.items << x
  }

  primes.filter(fn(item u64, primes List[u64]) bool {
    if item < 2 {
      return false
    }

    if item == 2 {
      return true
    }
    if item % 2 == 0 {
      return false
    }

    for x in primes.items {
      if x * x > item {
          panic("overflow!")
      }

      if item % x == 0 {
          return false
      }
    }

    return true // No divisors found after checking all necessary primes
  })
  println("prime numbers are: ${primes}")
  return
}