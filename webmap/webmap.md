
# Module:
- main

## Dependencies:
```v
// for http requests!
import net.http { get }
// for parsing html!
import net.html { parse }
// for parsing safe urls!
import net.urllib
```

## Functions:
```v
//
// Main function, handles arguments and does some things.
//
fn main() {
```
```v
//
// this function iterates over every link found on first page and goes to them untill last page is done!!
//
fn crawl(la_url urllib.URL, depth int, max_depth int, mut visited map[string]bool, mut results []string) {
```

## Structs:
