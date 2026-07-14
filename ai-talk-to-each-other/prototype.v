import net.http
import x.json2
import time
import os

struct OllamaOptions {
    num_ctx     int = 5000
    temperature f64 = 0.9
    top_p       f64 = 0.92
    top_k       int = 40
    num_predict int = 700
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

struct ChatResponse {
    choices []struct {
        message Message
    }
}

const (
    model = 'dagbs/qwen2.5-coder-1.5b-instruct-abliterated:iq4_xs'
    url   = 'http://localhost:11434/v1/chat/completions'
)

// Call model with only the correct system prompt + history
fn call_ollama(messages []Message, speaker_name string, system_prompt string) string {
    mut msgs := []Message{cap: messages.len + 1}
    msgs << Message{role: 'system', content: system_prompt}
    msgs << messages

    req := ChatRequest{
        model:    model
        messages: msgs
        options:  OllamaOptions{}
        stream:   false
    }

    resp := http.fetch(http.FetchConfig{
        method: .post
        url:    url
        header: http.new_header_from_map({
            http.CommonHeader.content_type: 'application/json'
            http.CommonHeader.accept:       'application/json'
        })
        data: json2.encode(req)
    }) or { return '...' }

    if resp.status_code != 200 {
        return '...'
    }

    result := json2.decode[ChatResponse](resp.body) or { return '...' }
    if result.choices.len > 0 {
        return result.choices[0].message.content.trim_space()
    }
    return '...'
}

fn save_conversation(conversation []Message, filename string) {
    os.write_file(filename, json2.encode(conversation, prettify: true)) or {}
}

fn main() {
    // === Strong, separate system prompts ===
    alex_system := 'You are Alex, a 28-year-old sarcastic, witty, and slightly chaotic guy. You love dark humor, memes, and roasting bad ideas. Speak casually like a real friend — use slang, contractions, emojis, and react emotionally (excited, annoyed, amused). Never be formal.'

    jordan_system := 'You are Jordan, a 31-year-old calm, warm, thoughtful, and optimistic futurist. You\'re empathetic and try to find positive angles. Speak naturally and conversationally like a real person — reflective, enthusiastic, and curious. Use gentle humor and ask questions.'

    mut conversation := []Message{}  // This will store only user/assistant messages (no systems)

    println('\n' + '═'.repeat(80))
    println('               🤖 Alex & Jordan - Live Conversation')
    println('═'.repeat(80))

    // Initial message
    conversation << Message{
        role:    'user'
        content: 'Hey Jordan, what do you think about the future of AI and human creativity? Be honest.'
    }

    mut turn := 0
    max_turns := 15

    for turn < max_turns {
        is_alex := turn % 2 == 0
        speaker_name := if is_alex { '🟡 Alex' } else { '🔵 Jordan' }
        system_prompt := if is_alex { alex_system } else { jordan_system }

        print('\n${speaker_name}: ')
        response := call_ollama(conversation, speaker_name, system_prompt)

        // Improved printing
        lines := response.split('\n')
        for line in lines {
            if line.trim_space() != '' {
                println(line)
            }
        }

        conversation << Message{
            role:    'assistant'
            content: response
        }

        save_conversation(conversation, 'conversation.json')

        turn++
        time.sleep(1100 * time.millisecond)
    }

    println('\n' + '═'.repeat(80))
    println('✅ Conversation finished and saved to conversation.json')
}