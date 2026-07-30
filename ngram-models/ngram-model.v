module main

/*
from collections import defaultdict, Counter
import re

corpus = """
The cat sat on the mat. The dog sat on the rug.
The cat chased the mouse. The dog barked at the cat.
"""

def tokenize(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)  # Remove punctuation
    return text.split()

words = tokenize(corpus)

# Structure: { previous_word: { current_word: count } }
bigram_model = defaultdict(Counter)

for i in range(len(words) - 1):
    prev_word = words[i]
    curr_word = words[i+1]
    bigram_model[prev_word][curr_word] += 1

def get_next_word_probabilities(word):
    word = word.lower()
    if word not in bigram_model:
        return "Word not found in corpus history."

    total_count = sum(bigram_model[word].values())
    probabilities = {next_w: count / total_count for next_w, count in bigram_model[word].items()}
    return sorted(probabilities.items(), key=lambda x: x[1], reverse=True)

print("Predictions for 'the':", get_next_word_probabilities("the"))
print("Predictions for 'cat':", get_next_word_probabilities("cat"))
*/

fn tokenizer(corpus string) []string {
  /* - I will use bpe for tokenization.
     - But for now, lets just use words!
  */
  mut tokens := string

  for delim in ",.:;'()!? ".str().split("") {
    tokens = tokens.split(delim).join("|${delim}|")
  }

  return tokens.split("|")
}

fn train(tokens []string) map[string]map[string]f64 {
  mut ngram_model := map[string]map[string]f64

  for i in 0..tokens.len-2 {
    this_word := tokens[i]
    next_word := tokens[i+1]
    ngram_model[this_word][next_word] += 0.1
  }

  for this_word in ngram_model {

  }

  return ngram_model
}

fn main() {
  /*

    1. tokenize.
    2. train.
    3. generate.

  */

  /* Tokenization:
  */

  corpus_data_file = "./../.ignore_this/raw_data.txt"
  corpus_data = os.read_file(corpus_data_file) or {
    eprintln("failed to read file ${corpus_data_file}")
    return
  }


  /* Training:
  */


  /* Geanration:
  */

  return
}