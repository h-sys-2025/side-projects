import net.http
import json

// Define a struct for the options to keep code clean
struct OllamaOptions {
    num_ctx         int     = 4096  // Context window size
    temperature     f64     = 0.8   // Creativity (0.0 - 2.0)
    top_p           f64     = 0.9   // Nucleus sampling
    top_k           int     = 40    // Top-K sampling
    min_p           f64     = 0.05  // Minimum probability threshold
    repeat_penalty  f64     = 1.1   // Repetition penalty
    num_predict     int     = -1    // Max tokens to generate (-1 for infinite)
    seed            int     = 0     // Random seed (0 for random)
}

fn main() {
    url := 'http://localhost:11434/v1/chat/completions'
    model := 'dagbs/qwen2.5-coder-1.5b-instruct-abliterated:iq4_xs'

    // 1. Configure sampling parameters
    opts := OllamaOptions{
        num_ctx:        8192
        temperature:    0.7
        top_p:          0.9
        top_k:          40
        min_p:          0.05
        repeat_penalty: 1.1
        num_predict:    512
    }

    // 2. Build the JSON payload manually to ensure 'options' is included correctly
    // Note: The OpenAI-compatible endpoint expects 'options' at the root level alongside 'model' and 'messages'
    payload := `{
        "model": "${model}",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Explain quantum entanglement simply."}
        ],
        "options": {
            "num_ctx": ${opts.num_ctx},
            "temperature": ${opts.temperature},
            "top_p": ${opts.top_p},
            "top_k": ${opts.top_k},
            "min_p": ${opts.min_p},
            "repeat_penalty": ${opts.repeat_penalty},
            "num_predict": ${opts.num_predict},
            "seed": ${opts.seed}
        },
        "stream": false
    }`

    // 3. Set headers
    headers := http.new_header_from_map({
        http.CommonHeader.content_type: 'application/json'
        http.CommonHeader.accept:       'application/json'
    })

    // 4. Send request
    conf := http.FetchConfig{
        method:     .post
        url:        url
        header:     headers
        data:       payload
        user_agent: 'v-ollama-advanced'
    }

    resp := http.fetch(conf) or {
        eprintln('Request failed: ${err}')
        return
    }

    // 5. Parse and print response
    if resp.status_code == 200 {
        mut json_resp := json.parse(resp.body) or {
            eprintln('JSON parse error: ${err}')
            return
        }

        choices := json_resp['choices'] or { [] }
        if choices.len > 0 {
            message := choices[0]['message'] or { {} }
            content := message['content'] or { 'No content' }
            println('Response:\n${content}')
        }
    } else {
        eprintln('Error ${resp.status_code}: ${resp.body}')
    }
}