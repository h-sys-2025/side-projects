module main

fn main() {
    mut program := 'module main
fn main() {
    mut program := "?"
    println(escape(program))
}
fn escape(program string) string {
    mut esc := ""
    for c in program {
        if c == `\\` {
            esc += "\\\\"
        } else if c == `"` {
            esc += "\\\""
        } else if c == `\n` {
            esc += "\\n"
        } else {
            esc += c.str()
        }
    }
    return esc
}'

    println('module main
fn main() {
    mut program := "' + escape(program) + '"
    println(escape(program))
}
fn escape(program string) string {
    mut esc := ""
    for c in program {
        if c == `\\` {
            esc += "\\\\"
        } else if c == `"` {
            esc += "\\\""
        } else if c == `\n` {
            esc += "\\n"
        } else {
            esc += c.str()
        }
    }
    return esc
}')
}

fn escape(program string) string {
    mut esc := ""
    for c in program {
        if c == `\\` {
            esc += "\\\\"
        } else if c == `"` {
            esc += "\\\""
        } else if c == `\n` {
            esc += "\\n"
        } else {
            esc += c.str()
        }
    }
    return esc
}