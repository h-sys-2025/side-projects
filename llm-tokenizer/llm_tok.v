module main

import bpe
import os
import rand
import json
import math

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
    mut data := os.read_file(data_file) or {
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
    // test: println("table: ${tt}")
    // test:println(tokenizer(bpe_ed, tt))
    // println(bpe.please_decode_this(bpe_ed, tt))
    tokens := tokenizer(bpe_ed, tt)
    println(tokens)
    // for markov chain, it has IQ of -999
    // oorder := 10
    // model := build_model(tokens.split("|"), oorder)
    // test: println(model)

    // model_json := json.encode(model)
    // os.write_file("./model.json",model_json) or {
        // eprintln(err)
        // return
    // }
    // result := predict_n(model, "it", 20, 0.5)

    //println(result.join(" ").split("  ").join("|").split(" ").join(""))
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



///----///

//@ this function generates a markov-chain model with order (for markov chain)
//@
//@ a little vibecoding never hurtes anyone: Generates Order-N Model using single string keys (e.g., "a|b|c")
//@
fn build_model(tokens []string, order int) map[string]map[string]f64 {
    mut model := map[string]map[string]f64{}

    if tokens.len < 2 {
        println("Warning: Too few tokens (${tokens.len})")
        return model
    }

    for i := 0; i < tokens.len; i++ {
        // Try all possible context lengths (from_len) from 1 to `order`
        for from_len := 1; from_len <= order; from_len++ {
            if i + from_len > tokens.len {
                break
            }
            mut from_parts := []string{}
            for j := 0; j < from_len; j++ {
                from_parts << tokens[i + j]
            }
            from := from_parts.join('|')

            // Try all possible prediction lengths (to_len) from 1 to `order`
            for to_len := 1; to_len <= order; to_len++ {
                if i + from_len + to_len > tokens.len {
                    break
                }
                mut to_parts := []string{}
                for j := 0; j < to_len; j++ {
                    to_parts << tokens[i + from_len + j]
                }
                to := to_parts.join('|')

                if from !in model {
                    model[from] = map[string]f64{}
                }
                model[from][to] += 1.0
            }
        }
    }

    // Normalize probabilities safely in V
    for from, _ in model {
        mut total := 0.0
        for _, count in model[from] {
            total += count
        }
        if total > 0 {
            for to, count in model[from] {
                model[from][to] = count / total
            }
        }
    }

    return model
}

//@ for markov chain
//@ predict_n: Main prediction function with backoff and multi-token support
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
    if n <= 0 { return []string{} }

    mut predictions := []string{}
    // Normalize prompt to use '|' as separator for multi-word prompts
    mut current_context := prompt.replace(" ", "|")
    for _ in 0..n {
        mut next := get_next_with_backoff(model, current_context, temperature)
        if next == "" { break }

        // Split the predicted sequence into individual tokens
        // (e.g., "was|a" becomes "was" and "a" for clean final output)
        for token in next.split('|') {
            predictions << token
        }

        // The new context is the predicted sequence itself.
        // Since `to_len` <= `order`, `next` has at most `order` tokens.
        // The backoff mechanism naturally handles it (e.g., "was|a" -> "a" if "was|a" isn't found).
        current_context = next
    }
    return predictions
}

//@ get_next_with_backoff: Variable order backoff
fn get_next_with_backoff(model map[string]map[string]f64, context string, temperature f64) string {
    mut ctx := context
    for {
        if ctx in model && model[ctx].len > 0 {
            return sample_with_temperature(model[ctx], temperature)
        }
        parts := ctx.split('|')
        if parts.len <= 1 { break }
        ctx = parts[1..].join('|')
    }

    // Single word fallback
    words := context.split('|')
    for i := words.len - 1; i >= 0; i-- {
        if words[i] in model && model[words[i]].len > 0 {
            return sample_with_temperature(model[words[i]], temperature)
        }
    }
    return ""
}

//@ sample_with_temperature: Temperature sampling
fn sample_with_temperature(dist map[string]f64, temperature f64) string {
    if temperature <= 0.0 {
        mut best := ""
        mut best_prob := -1.0
        for tok, prob in dist {
            if prob > best_prob {
                best_prob = prob
                best = tok
            }
        }
        return best
    }

    mut total := 0.0
    mut candidates := []string{}
    mut probs := []f64{}

    for tok, p in dist {
        if p > 0 {
            scaled := math.pow(p, 1.0 / temperature)
            candidates << tok
            probs << scaled
            total += scaled
        }
    }

    if total <= 0 || candidates.len == 0 {
        return candidates[0] or { "" }
    }

    for i in 0..probs.len {
        probs[i] /= total
    }

    r := rand.f64()
    mut cum := 0.0
    for i in 0..probs.len {
        cum += probs[i]
        if r <= cum {
            return candidates[i]
        }
    }
    return candidates.last()
}