module main

import bpe {
    please_encode_this,
    please_decode_this
}

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
    mut data := os.read_file(data_file) or {
        eprintln("could not read file ${data_file}: ${err}")
        return
    }

    // test: println(data)

    // 2. tokenizer? nah, formatting first!
    // - It means, removing all tabs, and extra spaces first!
    mut formatted := data


    println(formatted)
    return
}