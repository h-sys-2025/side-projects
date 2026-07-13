module main

import os
import math
import rand
import strings

fn main() {
    corpus_file_path := "./small_data.txt"

    fmt_corpus(corpus_file_path)
    data := get_data(corpus_file_path)

    println("Raw data length: ${data.len} characters")

    tokenized := tokenize(data)
    println("Tokens count: ${tokenized.len}")
    if tokenized.len > 0 {
        println("First 15 tokens: ${tokenized[0..min(15, tokenized.len)]}")
    }

    model := build_model(tokenized, 2)
    println(model)
    println("Model size: ${model.len} contexts")

    if model.len == 0 {
        println("ERROR: Model is empty! Check your data/tokenization.")
        return
    }

    println("\nGenerating prediction from 'helicopter'...")
    result := predict_n(model, "helicopter", 20, 0.75)
    println(result.join(" "))

    return
}

//@ predict_n: Main prediction function with backoff
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
    if n <= 0 { return []string{} }

    mut predictions := []string{}
    mut current_context := prompt

    for _ in 0..n {
        next := get_next_with_backoff(model, current_context, temperature)
        if next == "" { break }
        predictions << next
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

//@ build_model: Fixed sliding window
fn build_model(tokens []string, order int) map[string]map[string]f64 {
    mut model := map[string]map[string]f64{}

    if tokens.len < 4 {
        println("Warning: Too few tokens (${tokens.len})")
        return model
    }

    for level := 1; level <= order; level++ {
        for i := 0; i <= tokens.len - 2*level; i++ {
            mut from_parts := []string{}
            for j := 0; j < level; j++ {
                from_parts << tokens[i + j]
            }
            from := from_parts.join('|')

            mut to_parts := []string{}
            for j := 0; j < level; j++ {
                if i + level + j >= tokens.len { break }
                to_parts << tokens[i + level + j]
            }
            if to_parts.len != level { continue }

            to := to_parts.join('|')

            if from !in model {
                model[from] = map[string]f64{}
            }
            model[from][to] += 1.0
        }
    }

    // Normalize
    for _, mut transitions in model {
        mut total := 0.0
        for _, count in transitions {
            total += count
        }
        if total > 0 {
            for to, count in transitions {
                transitions[to] = count / total
            }
        }
    }

    return model
}

//@ tokenize: Much better tokenizer (the real fix)
fn tokenize(data string) []string {
    if data.len == 0 {
        return []string{}
    }

    mut text := data.to_lower()

    // Replace common punctuation with space or |
    text = text.replace_each([
        ".", " | ",
        "!", " | ",
        "?", " | ",
        ",", " | ",
        ";", " | ",
        ":", " | ",
        "(", " | ",
        ")", " | ",
        "[", " | ",
        "]", " | ",
        "{", " | ",
        "}", " | ",
        "\"", " | ",
        "'", " | ",
        "\n", " | ",
        "\t", " | ",
        "—", " | ",
    ])

    // Split on whitespace and |
    mut tokens := []string{}
    for word in text.split_any(" \t\n|") {
        trimmed := word.trim_space()
        if trimmed.len > 0 {
            tokens << trimmed
        }
    }

    return tokens
}

//@ get_data
fn get_data(file_path string) string {
    data := os.read_file(file_path) or {
        eprintln("Error reading file: ${err}")
        return ""
    }
    return data
}

//@ fmt_corpus: Corpus cleaning
const prohibited_chars := "[]—"

fn fmt_corpus(file_path string) {
    mut corpus := os.read_file(file_path) or { return }

    for x in prohibited_chars.str().split("") {
        if x != "" {
            corpus = corpus.split(x).join(" ")
        }
    }

    corpus = corpus.split(".").join(" .\n")
    corpus = corpus.replace("\n\n", "\n")
    corpus = corpus.replace("\n ", "\n")

    mut lines := []string{}
    for line in corpus.split("\n") {
        if line.trim_space() != "" {
            lines << line.trim_space()
        }
    }

    os.write_file(file_path, lines.join("\n").to_lower()) or {}
}

// Helper
fn min(a int, b int) int {
    return if a < b { a } else { b }
}