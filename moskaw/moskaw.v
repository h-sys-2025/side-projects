module main

import os
import math
import rand

fn main() {
    corpus_file_path := "./raw_data.txt"

    // Ensure file exists for testing if you don't have one
    if !os.exists(corpus_file_path) {
        os.write_file(corpus_file_path, "The helicopter was in the air. It was not a bird. The bird was small.") or {}
    }

    fmt_corpus(corpus_file_path)
    data := get_data(corpus_file_path)

    tokenized := tokenize(data)

    // Order 2 allows predicting up to 2 tokens ahead
    model := build_model(tokenized, 2)
    println("Model size: ${model.len} contexts")

    if model.len == 0 {
        println("ERROR: Model is empty!")
        return
    }

    println("\nGenerating prediction from 'the'...")
    result := predict_n(model, "the", 15, 0.7)

    // Clean up the output: remove internal tags and fix spacing around punctuation
    clean_output(result)
}

//@ clean_output: Formats the raw token list into readable text
fn clean_output(tokens []string) {
    mut text := ""
    for i, tok in tokens {
        if tok == "<s>" || tok == "</s>" { continue }

        // Add space before word, but NOT before punctuation
        if i > 0 && tok != "." && tok != "," && tok != "!" && tok != "?" && tok != ";" && tok != ":" {
            text += " "
        }
        text += tok
    }
    println(text.trim_space())
}

//@ predict_n: Prediction with sentence boundary handling
fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
    if n <= 0 { return []string{} }

    mut predictions := []string{}
    // Start with <s> to give the model a "beginning of sentence" context
    mut current_context := "<s>"

    // If user provided a prompt, add it to the context
    if prompt.len > 0 {
        prompt_tokens := tokenize(prompt)
        for t in prompt_tokens {
            current_context += "|" + t
        }
    }

    for _ in 0..n {
        next_seq := get_next_with_backoff(model, current_context, temperature)
        if next_seq == "" { break }

        // Split multi-token predictions (e.g., "was|a")
        for token in next_seq.split('|') {
            predictions << token

            // INTELLIGENCE: If we hit an end-of-sentence marker, reset context
            if token == "</s>" {
                current_context = "<s>"
            } else {
                // Update context normally
                if current_context == "<s>" {
                    current_context = token
                } else {
                    current_context += "|" + token
                }

                // Keep context length manageable (max order)
                parts := current_context.split('|')
                if parts.len > 2 { // Assuming order 2 max context
                    current_context = parts[1..].join('|')
                }
            }
        }

        // Stop if we've generated enough real words (excluding tags)
        real_count := 0
        for p in predictions {
            if p != "<s>" && p != "</s>" { real_count++ }
        }
        if real_count >= n { break }
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

//@ build_model: Builds model with sentence boundaries
fn build_model(tokens []string, order int) map[string]map[string]f64 {
    mut model := map[string]map[string]f64{}

    // Prepend <s> and append </s> to every "sentence" in the token stream
    // For simplicity in this demo, we treat the whole corpus as one flow,
    // but we look for '.' '!' '?' to insert </s> <s>
    mut processed_tokens := []string{"<s>"}
    for t in tokens {
        processed_tokens << t
        if t == "." || t == "!" || t == "?" {
            processed_tokens << "</s>"
            processed_tokens << "<s>"
        }
    }

    if processed_tokens.len < 2 { return model }

    for i := 0; i < processed_tokens.len; i++ {
        for from_len := 1; from_len <= order; from_len++ {
            if i + from_len > processed_tokens.len { break }

            mut from_parts := []string{}
            for j := 0; j < from_len; j++ {
                from_parts << processed_tokens[i + j]
            }
            from := from_parts.join('|')

            for to_len := 1; to_len <= order; to_len++ {
                if i + from_len + to_len > processed_tokens.len { break }

                mut to_parts := []string{}
                for j := 0; j < to_len; j++ {
                    to_parts << processed_tokens[i + from_len + j]
                }
                to := to_parts.join('|')

                if from !in model {
                    model[from] = map[string]f64{}
                }
                model[from][to] += 1.0
            }
        }
    }

    // Normalize
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

//@ tokenize: Intelligent tokenizer keeping punctuation as words
fn tokenize(data string) []string {
    if data.len == 0 { return []string{} }

    mut text := data.to_lower()
    mut tokens := []string{}
    mut current_word := ""

    for char in text {
        s := char.str()
        // Check if character is punctuation
        if s == "." || s == "," || s == "!" || s == "?" || s == ";" || s == ":" || s == "(" || s == ")" || s == "\"" || s == "'" {
            if current_word.len > 0 {
                tokens << current_word
                current_word = ""
            }
            tokens << s
        } else if s == " " || s == "\n" || s == "\t" {
            if current_word.len > 0 {
                tokens << current_word
                current_word = ""
            }
        } else {
            current_word += s
        }
    }
    if current_word.len > 0 {
        tokens << current_word
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

//@ fmt_corpus: Basic cleaning
fn fmt_corpus(file_path string) {
    mut corpus := os.read_file(file_path) or { return }
    // Remove weird characters but keep standard punctuation
    corpus = corpus.replace("—", " ")
    os.write_file(file_path, corpus) or {}
}