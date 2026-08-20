#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
  @desc: simple abstraction for slice statements in C language. only works for `char*` for now.
  @usage: auto slice(char*, size_t, size_t) -> char* {...}
*/
char *slice(char *sentence, size_t i, size_t j) {
  if (j > strlen(sentence)) {
    // memory safety.
    return NULL;
  }

  if (i < 0) i = 0;

  // the lenght of resultant slice.
  size_t len = j - i;

  // memory allocation for slice.
  char *res = malloc(
    (len + 1) * sizeof(char)
  );
  if (res == NULL) {
    return res;
  }

  size_t u = 0;
  while (u < len) {
    res[u] = sentence[i+u];
    u++;
  }
  res[u] = '\0'; // a trailing null byte.

  return res;
}

int main() {
  char *sentence = "The quick brown fox jumps off a lazy dog.";
  char *sliced   = slice(sentence, 11, 29);

  if (sliced != NULL) {
    printf("%s\n", sliced); // Outputs: "ck brown fox "

    free(sliced);
  }

  return 0;
}