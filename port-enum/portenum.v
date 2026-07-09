module main

import os

fn main() {
    if arguments().len < 2 {
        eprintln("portenum: usage: ${arguments()[0]} <ip>")
        return
    }

    scan_w_fmt(parse_safe_ip(arguments()[1]))
    return
}

fn scan_w_fmt(ip string) {
    println("starting scan on ${ip}")
    for x in 0..1000 {
        res := os.execute("nc -v -n -w 1 ${ip} ${x}")
        println("port: ${x} on ${ip}: ${res.output}")
    }
}

fn parse_safe_ip(make_believe_ip string) string {
    mut here_you_go := make_believe_ip
    u1 := make_believe_ip.split(".")
    if u1.len != 4 {
        eprintln("parse_safe_ip: ip format is this: `1.2.3.4`. (type is: [4]u8) ${make_believe_ip}")
        return ""
    }
    for x in u1 {
        if x.int() > 255 || x.int() < 0 {
            eprintln("parse_safe_ip: pleaseeee! ip format is wrong! ${make_believe_ip}")
            return ""
        }
    }
    return here_you_go
}