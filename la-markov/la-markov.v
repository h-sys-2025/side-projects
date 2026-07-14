module main

import os

import rand

fn main() {
    /*

    idea:

    1. get text data?
    2. generate model file.
    3. try it.

    */

    corpos_file_path := "./../.ignore_this/raw_data.txt"
    // testing reformat: fmt_corpus(corpos_file_path)

    data := get_data(corpos_file_path)

    order := 2
    model := gen_model_n(data, order)

    //println(model)
    println(predict_n(model, "remaining tobacco", 50, order))
    return
}

//@
//@ This function reads the corpus file
//@
fn get_data(file_path string) string {
    data := os.read_file(file_path) or {
        eprintln("error reading file ${file_path}: ${err}")
        return ""
    }
    return data
}

//@
//@ This function takes in curpos data as input and generates a json based markov chain model!
//@
fn gen_model(corpus string) map[string]map[string]f64 {
    mut model := map[string]map[string]f64

    u1 := tokenize(corpus.to_lower()) // we lower it to make it simple, and provide more results!

    // test:
    // for word in u1.split("|") {
    //     println("${word}")
    // }

    // for stats
    // did this for 30 mins for no reason at all, v is hell when it comes to sorting!
    // test: sorted_tokens := count_tokens_occurrences(u1.split("|"))

    tokens := u1.split("|")
    for i in 0..tokens.len-1 {
        tok := tokens[i]
        next := tokens[i+1]
        // test: println("${tok} => ${next}")
        model[tok][next] += 0.1

        // test: println("${i} => ${tok} (occcurred ${sorted_tokens[tok]} times)")
    }

    // test: println(u1)
    return model
}

//@
//@ a little vibecoding never hurtes anyone: Generates Order-N Model using single string keys (e.g., "a|b|c")
//@
fn gen_model_n(corpus string, order int) map[string]map[string]f64 {
    mut model := map[string]map[string]f64
    tokens := tokenize(corpus.to_lower()).split("|")

    if tokens.len <= order {
        return model
    }

    for i in 0 .. tokens.len - order - 1 {
        // 1. Build the key string directly from the slice
        // Example Order 2: tokens[i] + "|" + tokens[i+1]
        mut key_parts := tokens[i .. i + order].clone()
        key := key_parts.join("|")

        next := tokens[i + order]

        model[key][next] += 1.0
    }

    return model
}

//@ Helper: selects a random key from a map[string]f64 based on weights (probabilities)
fn pick_weighted(next_map map[string]f64) string {
    if next_map.len == 0 {
        return ""
    }

    // 1. Calculate total weight
    mut total := 0.0
    for _, v in next_map {
        total += v
    }

    // 2. Get random number between 0 and total
    r := rand.f64() * total

    // 3. Iterate and find the weighted key
    mut running := 0.0
    for k, v in next_map {
        running += v
        if r < running {
            return k
        }
    }

    // Fallback (should theoretically not reach here due to float precision edge cases)
    for k, _ in next_map {
        return k
    }
    return ""
}

//@ the main thing, the mighty prediction function! it does the job!!!
fn predictoin(model map[string]map[string]f64, prompt string, n int) []string {
    mut result := []string{}

    // Split prompt to get the starting token
    tokens := prompt.split(" ")
    if tokens.len == 0 {
        return result
    }
    mut current_token := tokens[tokens.len - 1]

    for _ in 0 .. n {
        next_map := model[current_token].clone()

        // If no next words exist for this token, stop
        if next_map.len == 0 {
            break
        }

        // Pick a random next word based on probabilities
        next_word := pick_weighted(next_map)

        if next_word == "" {
            break
        }

        result << next_word
        current_token = next_word
    }

    return result
}

//@
//@ Predicts using single string keys. No slice history management needed inside loop.
//@
fn predict_n(model map[string]map[string]f64, prompt string, n int, order int) []string {
    mut result := []string{}

    // 1. Prepare initial key from prompt
    // User provides "markov chain", we need "markov|chain"
    mut key_parts := prompt.split(" ")
    if key_parts.len < order {
        return result
    }

    // Take last 'order' words and join with '|'
    key_parts = key_parts[key_parts.len - order .. key_parts.len].clone()
    mut current_key := key_parts.join("|")

    for _ in 0 .. n {
        next_map := model[current_key].clone()

        if next_map.len == 0 {
            break // Dead end
        }

        next_word := pick_weighted(next_map)
        if next_word == "" {
            break
        }

        result << next_word

        // 2. Slide the window using string operations
        // Split current key, drop first, append new word, join again
        mut parts := current_key.split("|")

        // Remove first element (shift left)
        parts = parts[1 .. order].clone()

        // Add new word
        parts << next_word

        // Rebuild key string
        current_key = parts.join("|")
    }

    return result
}

//@ const of tokenizer-delims
const tokenizer_delims := ".,::'\"(){} "
//@ const of anti-delim for tokenizer
const anti_delim := "|"


//@ util func: this function tokenizes every word in provided corpus. - it does some long repititive tasks!
fn tokenize(corpus string) string {
    mut ccorpus := corpus.split("\n").join("|")
    for x in tokenizer_delims.str().split("") {
        // v has some unexpected string-related shit!!!, but its okay.
        // test: println("delim: ${x.str()} joiner: ${anti_delim.str()}")
        ccorpus = ccorpus
           .split(x.str())
           .join(anti_delim.str())
    }
    cont_fmt: for {
        ccorpus = ccorpus.split("||").join("|")
        if ccorpus.contains("||") {
            continue cont_fmt
        } else {
            break
        }
    }
    return ccorpus
}

//@ util func: count number of times word is occurred!
fn count_tokens_occurrences(tokens []string) map[string]int {
    mut counts := map[string]int

    for token in tokens {
        counts[token] += 1
    }

    counts = sort_map(counts)

    return counts
}

//@ useless struct, v does not allow sorting???!!!!!
struct KV {
    key   string
    value int
}

//@ util func: sorts a map[string]int
fn sort_map(data map[string]int) map[string]int {
    mut items := []KV{}
    for k, v in data {
        items << KV{k, v}
    }

    // Sort by value (ascending). Use > for descending.
    items.sort_with_compare(fn (a &KV, b &KV) int {
        if a.value < b.value {
            return 1
        } else if a.value > b.value {
            return -1
        }
        return 0
    })

    //convert back to msp[string]int
    mut map_item := map[string]int
    for x in items {
        map_item[x.key] = x.value
    }

    return map_item
}

//@ constant of prohibited chars!
const prohibited_chars := "[]—"
//@ this is a temp function!
fn fmt_corpus(file_path string) {
    // test: println(" _*_ reading corpus file for reformatting _*_")
    mut corpus := os.read_file(file_path) or {
        eprintln(err)
        return
    }
    // test: println(" _*_ reformatting corpus file _*_")
    for x in prohibited_chars.str().split("") {
        // test: println(x.str())
        corpus = corpus.split((x).str()).join(" ")
    }
    corpus = corpus.split(".").join(".\n")
    corpus = corpus.split("\n\n").join("\n")
    corpus = corpus.split("  ").join(" ")
    // test: println(" _*_ saving reformatted file _*_")
    os.write_file(file_path, corpus.to_lower()) or {
        eprintln(err)
        return
    }
    return
}