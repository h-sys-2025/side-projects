module main

import os
import math
import rand

fn main() {
    /*

    idea:

    1. rewrite markov-chain from scratch AGAIN!

    */

    corpos_file_path := "./small_data.txt"
    fmt_corpus(corpos_file_path)

    data := get_data(corpos_file_path)
    tokenized := tokenize(data)
    // test: I feel majestic: println(tokenized.join("|"))
    model := build_model(tokenized, 2) // order=2
    // println(model)

    println(predict_n(model, "helicopter", 10, 0.5))
    return
}

//@ this is the predict function!
//@ predict_n(map[string]map[string]f64) []string
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
    if n <= 0 {
        return []string{}
    }

    mut predictions := []string{}
    mut last := prompt  // expected to be in the same joined format as model keys (e.g. "helicopter" or "word1|word2")

    for _ in 0..n {
        if last !in model {
            // Fallback if we reach unknown state
            break
        }

        possibilities := model[last].clone()

        if possibilities.len == 0 {
            break
        }

        // Sample next token/block with temperature
        next := sample_with_temperature(possibilities, temperature)

        predictions << next
        last = next  // move window forward
    }

    return predictions
}

//@ helper function: Temperature sampling
fn sample_with_temperature(dist map[string]f64, temperature f64) string {
    if temperature <= 0.0 {
        // Greedy: return most probable
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

    // Apply temperature + softmax
    mut total := 0.0
    mut candidates := []string{}
    mut probs := []f64{}

    for tok, p in dist {
        if p <= 0 { continue }
        scaled := math.pow(p, 1.0 / temperature)
        candidates << tok
        probs << scaled
        total += scaled
    }

    if total == 0 {
        // fallback
        return candidates[0] or { "" }
    }

    // Normalize
    for i in 0..probs.len {
        probs[i] /= total
    }

    // Roulette wheel selection
    r := rand.f64()  // random value between 0 and 1
    mut cum := 0.0

    for i in 0..probs.len {
        cum += probs[i]
        if r <= cum {
            return candidates[i]
        }
    }

    // Fallback
    return candidates.last()
}

//@ this functions builds them model, the way I think it must!
//@ build_model([]string) map[string]map[string]f64
fn build_model(tokens []string, order int) map[string]map[string]f64 {
    mut model := map[string]map[string]f64{}

    for level := 1; level <= order; level++ {
        for i := 0; i <= tokens.len - 2*level; i++ {  // proper sliding window
            // Build "from" (level tokens)
            mut from_parts := []string{}
            for j := 0; j < level; j++ {
                from_parts << tokens[i + j]
            }
            from := from_parts.join('|')

            // Build "to" (next level tokens)
            mut to_parts := []string{}
            for j := 0; j < level; j++ {
                to_parts << tokens[i + level + j]
            }
            to := to_parts.join('|')

            if from !in model {
                model[from] = map[string]f64{}
            }
            model[from][to] += 1.0  // use count, not 0.1
        }
    }

    // Optional: normalize to probabilities
    for from, mut transitions in model {
        mut total := 0.0
        for _, count in transitions {
            total += count
        }
        for to, count in transitions {
            transitions[to] = count / total
        }
    }

    return model
}

//@ tokenize(string) []string
fn tokenize(data string) []string {
    mut raw_data := data

    delims := ".,?!'-:; "
    joiner := "|"
    for delim in delims.str().split("") {
        if delim.str() == "'" || delim.str() == "\"" {
            raw_data = raw_data.split(delim.str()).join("${delim.str()}${joiner.str()}")
        } else {
            raw_data = raw_data.split(delim.str()).join(joiner.str())
        }
    }
    // also split by `\n` new line char!
    raw_data = raw_data.split("\n").join(joiner.str())
    u1: for {
        if raw_data.contains("||") {
            // so we dont get `||` things.
            raw_data = raw_data.split("||").join("|")
            continue u1
        } else {
            break
        }
    }
    ttokens := raw_data.split("|")
    return ttokens
}
//@ just a wrapper for read_file!
fn get_data(file_path string) string {
    data := os.read_file(file_path) or {
        eprintln("error reading file ${file_path}: ${err}")
        return ""
    }
    return data
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
    corpus = corpus.replace("\n ","\n")

    mut new_corpus := []string{}
    for x in corpus.split("\n") {
        if x != "" {
            new_corpus << x
        }
    }
    new_corpus.join("\n")

    // test: println(" _*_ saving reformatted file _*_")
    os.write_file(file_path, new_corpus.join("\n").to_lower()) or {
        eprintln(err)
        return
    }
    return
}