#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline void isNULL(char* res) {
  if (res == NULL) abort(); // looking for NULL pointers.
}

/*
  # slice:
  - simple abstraction for slice things in `C` language. only supports `char*` for now.

  // syntax to use in `koilaC` (my implementation of  C).
  include "slice.so" {
    auto slice(char*, size_t, size_t) -> char* {...}
  }
*/
char *slice(char *sentence, size_t i, size_t j) {
  // safe-guards.
  if (sentence == NULL || i >= j) return NULL; // pointer trouble, null pointer derefrence and parameter polluting.

  size_t str_len = strlen(sentence);

  if (i >= str_len) return NULL; // You cannot start slicing where pointer data has already been ended.
  if (j > str_len) j = str_len;  // You cannot get more then you deserve.

  // length of resaltant slice data.
  size_t len = j - i;

  // critical memory allocation for slice, only `C` folkes might understand.
  char *res = malloc((len + 1) * sizeof(char));
  isNULL(res); // looking for NULL pointers.

  memcpy(res, &sentence[i], len); /* mov res, [sentence+len] */
  res[len] = '\0'; // also put a trailing null byte.

  return res;
}
/*
  blackhole89/macros --> supercool macros.
*/

// #define blackhole89
#ifdef blackhole89
  @define slice {
    ( @$arr [ @$start .. @$end ] ) => ( slice($arr, $start, $end) )
  }
#endif

// main
int main() {
  char *sentence = "The quick brown fox jumps higher then the lazy dog.";
  char *sliced = slice(sentence, 26, 51); // slice sentence[26..51]; // using `slice` macro

  if (sliced != NULL) { // pointer trouble.
    printf("%s\n", sliced);
    free(sliced);
  }

  #ifdef blackhole89
  printf("using slice macro: %s\n", slice sentence[26..51]);
  #endif
  return 0;
}