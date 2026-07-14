
# Module:
- 

## Dependencies:
```v
import net.http
import x.json2
import time
import os
```

## Constants:
```v
//PRIVATE

const (
```

## Functions:
```v
//PRIVATE

fn call_ollama(messages []Message, speaker_name string, system_prompt string) string {
```
```v
//PRIVATE

fn save_conversation(conversation []Message, filename string) {
```
```v
//PRIVATE

fn main() {
```

## Structs:
```v
//PRIVATE

struct OllamaOptions {
```
```v
//PRIVATE

struct Message {
```
```v
//PRIVATE

struct ChatRequest {
```
```v
//PRIVATE

struct ChatResponse {
```
