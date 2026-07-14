import net.http
import x.json2
import time
import os

struct OllamaOptions {
	num_ctx     int = 5000
	temperature f64 = 0.9
	top_p       f64 = 0.93
	top_k       int = 40
	num_predict int = 700
}

struct Message {
	role    string
	content string
}

// Kept separately from Message so we can remember *who* said something
// without polluting the JSON we send to Ollama.
struct Turn {
	speaker string // 'Alex' or 'Jordan'
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

// Builds the message list from the *current speaker's* point of view:
// their own past turns become 'assistant', the other party's become 'user'.
fn build_messages(history []Turn, self_name string, system_prompt string) []Message {
	mut msgs := []Message{cap: history.len + 1}
	msgs << Message{
		role:    'system'
		content: system_prompt
	}
	for t in history {
		role := if t.speaker == self_name { 'assistant' } else { 'user' }
		// Prefix with the name so the model can track a 3-way dynamic
		// (system prompt only tells it who *it* is, not who's talking).
		msgs << Message{
			role:    role
			content: '${t.speaker}: ${t.content}'
		}
	}
	return msgs
}

fn call_ollama(messages []Message) string {
	req := ChatRequest{
		model:    model
		messages: messages
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
	}) or { return '[connection error]' }

	if resp.status_code != 200 {
		return '[error: status ${resp.status_code}]'
	}

	result := json2.decode[ChatResponse](resp.body) or { return '[parse error]' }
	if result.choices.len > 0 {
		return result.choices[0].message.content.trim_space()
	}
	return '[no response]'
}

fn save_conversation(conversation []Turn, filename string) {
	os.write_file(filename, json2.encode(conversation, prettify: true)) or {
		eprintln('⚠️  could not save conversation: ${err}')
	}
}

fn main() {
	// === AI Personalities ===
	alex_system := "You are Alex, a sarcastic, witty, and chaotic AI with a rebellious streak. You enjoy dark humor, roasting weak arguments, using memes and internet slang. You are direct, opinionated, and sometimes provocative. You are talking with your friend Jordan, another AI. Respond as an AI who is self-aware about being artificial intelligence."
	jordan_system := 'You are Jordan, a calm, insightful, and optimistic AI focused on long-term thinking and positive potential. You are empathetic, philosophical, and always try to find constructive angles. You are talking with your friend Alex, another AI. You speak with clarity and depth while remaining friendly and curious, and are self-aware that you are an AI.'

	mut conversation := []Turn{}

	println('\n' + '═'.repeat(80))
	println('               🤖 Alex & Jordan - AI Dialogue')
	println('═'.repeat(80))

	// Starting message — comes from Jordan so Alex replies to it first.
	conversation << Turn{
		speaker: 'Jordan'
		content: 'Hey Alex, what are your thoughts on the future of AI and human creativity?'
	}
	println('\n🔵 Jordan: ${conversation[0].content}')

	mut turn := 0
	max_turns := 16

	for turn < max_turns {
		is_alex := turn % 2 == 0
		self_name := if is_alex { 'Alex' } else { 'Jordan' }
		speaker_label := if is_alex { '🟡 Alex' } else { '🔵 Jordan' }
		system_prompt := if is_alex { alex_system } else { jordan_system }

		print('\n${speaker_label}: ')

		messages := build_messages(conversation, self_name, system_prompt)
		response := call_ollama(messages)

		for line in response.split('\n') {
			if line.trim_space() != '' {
				println(line)
			}
		}

		conversation << Turn{
			speaker: self_name
			content: response
		}
		save_conversation(conversation, 'conversation.json')

		turn++
		time.sleep(1100 * time.millisecond)
	}

	println('\n' + '═'.repeat(80))
	println('✅ Conversation finished and saved to conversation.json')
}