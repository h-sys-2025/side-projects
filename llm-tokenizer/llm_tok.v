module main

import bpe
import os

fn main() {
    /*

    idea:

    key-points:
    - BPE: byte pair encoding!

    1. We do bpe on it, then reverse ir and generate a list of all things!!

    */

    // test: println(please_decode_this(please_encode_this("hello worlds, bb is watching!!")))

    // 1. first, we get the data/corpus/whatever.
    data_file := arguments()[1] or {
        "./../.ignore_this/raw_data.txt"
    }
    formatted_file := arguments()[2] or {
        "./../.ignore_this/formatted_data.txt"
    }
    mut data := os.read_file(formatted_file) or {
        eprintln("could not read file ${data_file}: ${err}")
        return
    }

    // test: println(data)

    // 2. tokenizer? nah, formatting first!
    // - It means, removing all tabs, and extra spaces first!

    // run just once: format_and_save(data, formatted_file)

    // this format does work, but is not what i want!
    // test: println(format_punctuation(format(data)).join("|"))
    ddata := format_punctuation(format(data)).join("|")
    // 3. now the tokenizer!
    // test: println(ddata)
    bpe_ed, tt := bpe.please_encode_this(ddata)
    println("table: ${tt}")
    println(tokenizer(bpe_ed, tt))
    // println(bpe.please_decode_this(bpe_ed, tt))
    return
}

//@ tokenizer function
//@ this function decodes it! - this takes the BPE-ed data and does it's thing!
fn tokenizer(message string, translation_table map[string]string) string {
    mut text := message
    for x,y in translation_table {
        text = text.replace(y,"|${x}|")
    }
    return text.split(bpe.space_replacer).join(" ").split(bpe.newline_replacer).join("\n").split("||").join("| |").split("||").join("|")
}

//@ const of punctuation
const punct := ".,?!:;'-"
//@ this function, turns punctuation into seperate tokens!
fn format_punctuation(tokens []string) []string {
    mut data := tokens.join("|")
    for x in punct.str().split("") {
        data = data.split(x.str()).join("|${x.str()}|")
    }
    data = data.split("\n").join("")
    data = data.split("||").join("|")
    return data.split("|")
}

//@ this function removes tabs and extra white spaces!
fn format(data string) []string {
    u1 := data.split(" ")
    mut formatted := []string{}
    next_x: for x in u1 {
        if x == "" {
            continue next_x
        }
        formatted << x
    }
    return formatted
}

//@ helper function: format and save to a file!
fn format_and_save(data string, formatted_file string) {
    os.write_file(formatted_file, format(data).join(" ")) or {
        eprintln("vould not write to file ${formatted_file}: ${err}")
    }
}