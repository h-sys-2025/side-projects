module main

fn main() {
    if arguments().len < 2 {
        eprintln("portenum: usage: ${arguments()[0]} <ip>:<port>")
        return
    }

    u1 := arguments()[1].split(":")
    if u1.len < 2 {
        eprintln("portenum: usage: ${arguments()[0]} <ip>:<port>")
        return
    }
    mut iip := u1[0]
    pport := u1[1]
    iip := parse_safe_ip(iip)

    println("starting scan on ip ${iip}:${pport}")

    return
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