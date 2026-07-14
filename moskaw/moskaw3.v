module main

import os
import rand

fn main() {
    corpus_file_path := "./../.ignore_this/raw_data.txt"

    // Ensure file exists for testing if you don't have one
    if !os.exists(corpus_file_path) {
        os.write_file(corpus_file_path, "The helicopter was in the air. It was not a bird. The bird was small.") or {}
    }

    data := get_data(corpus_file_path)

    prompt := "helicopter"
    order := 8
    nn := 5 // this measn 5 sentences

    println("${prompt}${predict_n(data, prompt, order, nn).join(" ").replace("  "," ")}")
}

//@ predict_n: Prediction with sentence boundary handling
fn predict_n(data string, prompt string, order int, nn int) []string {
    mut predict := []string{}

    u1 := prompt.split(" ")
    mut pprompt := u1[u1.len-1].to_lower()
    mut nnn := nn
    mut last := ""
    next_n: for {
        if nnn < 1 {
            break
        }

        next_possible_words := data.split(pprompt)
        next_word := rand.element(next_possible_words) or {
            return predict
        }
        mut nnext_word := next_word.split(" ")[..order]

        mut nnnext_word := nnext_word.join(" ")
        if nnnext_word == last {
            continue next_n
        }
        predict << nnnext_word

        last = nnnext_word
        nnn -= 1
    }

    return predict
}

//@ get_data
fn get_data(file_path string) string {
    data := os.read_file(file_path) or {
        eprintln("Error reading file: ${err}")
        return ""
    }
    return data
}