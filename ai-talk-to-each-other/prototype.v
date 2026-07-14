import net.http
import x.json2
import time
import os

struct OllamaOptions {
    num_ctx     int = 5000
    temperature f64 = 0.85
    top_p       f64 = 0.9
    top_k       int = 40
    num_predict int = 512
}

struct Message {
    role    string
    content string
}

struct ChatRequest {
    model    string
    messages []Message
    options  OllamaOptions
    stream   bool
}

struct Choice {
    message Message
}

struct ChatResponse {
    choices []Choice
}

const (
    model = 'dagbs/qwen2.5-coder-1.5b-instruct-abliterated:iq4_xs'
    url   = 'http://localhost:11434/v1/chat/completions'
)

fn call_ollama(messages []Message, persona_name string) string {
    opts := OllamaOptions{}

    req := ChatRequest{
        model:    model
        messages: messages
        options:  opts
        stream:   false
    }

    payload := json2.encode(req)

    headers := http.new_header_from_map({
        http.CommonHeader.content_type: 'application/json'
        http.CommonHeader.accept:       'application/json'
    })

    conf := http.FetchConfig{
        method: .post
        url:    url
        header: headers
        data:   payload
    }

    resp := http.fetch(conf) or {
        eprintln('${persona_name} request failed: ${err}')
        return 'Sorry, I had an error.'
    }

    if resp.status_code != 200 {
        eprintln('${persona_name} error ${resp.status_code}')
        return 'I encountered an error.'
    }

    result := json2.decode[ChatResponse](resp.body) or {
        eprintln('${persona_name} JSON decode error')
        return 'Sorry, parsing error.'
    }

    if result.choices.len > 0 {
        return result.choices[0].message.content.trim_space()
    }
    return 'No response.'
}

fn save_conversation(conversation []Message, filename string) {
    data := json2.encode(conversation, prettify: true)
    os.write_file(filename, data) or { eprintln('Failed to save conversation: ${err}') }
}

fn main() {
    mut conversation := []Message{}

    // === Personas ===
    conversation << Message{
        role:    'system'
        content: 'You are Alex, a witty, sarcastic, and slightly chaotic philosopher who loves debating ideas with humor.'
    }

    conversation << Message{
        role:    'system'
        content: 'You are Jordan, a calm, deeply insightful, and optimistic futurist who always tries to find common ground and positive outcomes.'
    }

    println('🤖 Starting conversation between Alex and Jordan...\n')
    println('═'.repeat(80))

    mut turn := 0
    max_turns := 20

    // Initial prompt
    conversation << Message{
        role:    'user'
        content: 'Start a conversation with Jordan about the future of artificial intelligence and human creativity.'
    }

    for turn < max_turns {
        current_speaker := if turn % 2 == 0 { 'Alex' } else { 'Jordan' }

        print('\n${current_speaker}: ')
        response := call_ollama(conversation, current_speaker)

        println(response)

        // Add response to history
        conversation << Message{
            role:    'assistant'
            content: response
        }

        save_conversation(conversation, 'conversation.json')

        turn++
        time.sleep(800 * time.millisecond)
    }

    println('\n═'.repeat(80))
    println('✅ Conversation finished! Saved to conversation.json')
}