module main

//@ for http requests!
import net.http { get }

//@ for parsing html!
import net.html { parse }

//@
//@ Main function, handles arguments and does some things.
//@
fn main() {
    prg := arguments()[0]
    mut url := arguments()[1] or {
        eprintln("${prg}: usage: ${prg} <url>")
        return
    }

    println(do_this_url(url, 0, 1))
    return
}

fn do_this_url(la_url string, depth int, max_depth int) []string {
    mut scavenged_links := []string
    if depth < max_depth {
        mut resp := get(la_url) or {
            eprintln("failed `get` request!")
            return scavenged_links
        }

        mut html_data := parse(resp.body)
        mut links := html_data.get_tags(name: 'a')
        for link in links {
            mut url := link.attributes['href'] or { continue }
            mut text := link.text()
            scavenged_links << "${url}"
            println('Crawling: label: `${text}` url: ${url}')
            scavenged_links << do_this_url(url, depth+1, max_depth)
        }
    } else {
        return scavenged_links
    }
    return scavenged_links
}