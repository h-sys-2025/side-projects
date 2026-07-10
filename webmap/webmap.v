module main

//@ for http requests!
import net.http { get }

//@ for parsing html!
import net.html { parse }

//@ for parsing safe urls!
import net.urllib

//@
//@ Main function, handles arguments and does some things.
//@
fn main() {
    prg := arguments()[0]
    mut url := arguments()[1] or {
        eprintln('${prg}: usage: ${prg} <url>')
        return
    }
    mut url_ref := urllib.parse(url) or {
        eprintln('url ${url} is not valid!')
        return
    }

    mut visited := map[string]bool{}
    mut all_links := []string{}

    // lets user pointers and refrences to d oour job!!! (awsome `c99` moment)
    crawl(url_ref, 0, 2, mut visited, mut all_links)

    println(' -*- found ${all_links.len} unique links:')
    for link in all_links {
        println(link)
    }

    return
}

//@
//@ this function iterates over every link found on first page and goes to them untill last page is done!!
//@
fn crawl(la_url urllib.URL, depth int, max_depth int, mut visited map[string]bool, mut results []string) {
    // Prevent infinite recursion and re-processing
    url_str := la_url.str()
    if url_str in visited || depth >= max_depth {
        return
    }
    visited[url_str] = true

    resp := get(la_url.str()) or {
        eprintln('failed to fetch $la_url: $err')
        return
    }

    // Correctly read the body as a string
    doc := parse(resp.body.str())
    links := doc.get_tags(name: 'a')

    for link in links {
        href := link.attributes['href'] or { continue }

        // Correct method name and argument order: base.resolve_reference(relative_url)
        full_url := la_url.resolve_reference(href) or { continue }
        full_url_str := full_url.str()

        // Skip if already visited before recursing
        if full_url_str in visited {
            continue
        }

        println('Crawling: `${link.text()}` -> $full_url_str')

        results << full_url_str

        crawl(full_url, depth + 1, max_depth, mut visited, mut results)
    }
}