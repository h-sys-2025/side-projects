#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

// macros, yas!
// first, basic abstact idea!
// start ////////

// c implementation:

typedef enum {
  i32, i64,
  u32, u64,
  f32, f64,

  // string,  // currently not implemented!
  // hashmap, // currently not implemented!

} ttype;

typedef struct {
  union {
    float f32;
    double f64;

    int32_t i32;
    int64_t i64;

    uint32_t u32;
    uint64_t u64;
  };
  ttype _type;
} any_t;
#define any any_t

// macros for casts or whatever //
#define f64(X) (any_t){._type = f64, .f64 = (X)}
#define f32(X) (any_t){._type = f32, .f32 = (X)}
#define u32(X) (any_t){._type = u32, .u32 = (X)}
#define u64(X) (any_t){._type = u64, .u64 = (X)}
#define i32(X) (any_t){._type = i32, .i32 = (X)}
#define i64(X) (any_t){._type = i64, .i64 = (X)}
// -- //

// macros for generic typechecks //
char* repr(ttype GType) {
  switch (GType) {
    case i32:
      return "i32";
    case i64:
      return "i64";
    case u32:
      return "u32";
    case u64:
      return "u64";
    case f32:
      return "f32";
    case f64:
      return "f64";
    default:
      return "unknown";
  }
}
#define typecheck(X,Y) if ((Y)._type != (X)) {printf("%s:%d type-mismatch! (expected type %s, got %s)", __FILE__, __LINE__, repr((X)), repr((Y)._type)); abort();}
// -- //

// println //
#define println(X,...) pprintln((X),(any[]){__VA_ARGS__})
#define DELIM "{:?}"
char** split_string(const char* str, const char* delim) {
    if (!str || !delim || !*delim) return NULL;

    size_t delim_len = strlen(delim);
    size_t count = 0;
    const char* temp = str;

    // 1. Count occurrences of the delimiter
    while ((temp = strstr(temp, delim)) != NULL) {
        count++;
        temp += delim_len;
    }

    // Number of tokens is count + 1
    size_t num_tokens = count + 1;

    // 2. Allocate the array of pointers (+1 for NULL sentinel)
    char** result = (char**)malloc((num_tokens + 1) * sizeof(char*));
    if (!result) return NULL;

    // 3. Split and copy tokens
    const char* start = str;
    const char* end;

    for (size_t i = 0; i < num_tokens; i++) {
        end = strstr(start, delim);

        size_t token_len = (end) ? (end - start) : strlen(start);

        // Allocate memory for the token (+1 for null terminator)
        result[i] = (char*)malloc(token_len + 1);
        if (!result[i]) {
            // Cleanup on failure
            for (size_t k = 0; k < i; k++) free(result[k]);
            free(result);
            return NULL;
        }

        // Copy the token
        memcpy(result[i], start, token_len);
        result[i][token_len] = '\0';

        // Move start pointer past the delimiter
        if (end) {
            start = end + delim_len;
        } else {
            break; // No more delimiters
        }
    }

    // 4. Set sentinel
    result[num_tokens] = NULL;

    return result;
}

void free_split(char** arr) {
    if (!arr) return;
    for (int i = 0; arr[i] != NULL; i++) {
        free(arr[i]);
    }
    free(arr);
}

void pprintln(const char* format, any items[]) {
  char** u1 = split_string(format, DELIM);
  char*  out_string = "";
  int lenght_of_fmt = sizeof(items) / sizeof(items[0]);
  for (size_t i = 0; u1[i] != NULL; i++) {
    char *string_msg = u1[i];
    ttype x;
    if (i < lenght_of_fmt) {
      x = items[i]._type;
    }
  }
}
// -- //

/* # Basic Example in V:
 * ```v
 * fn add[T](a T, b T) T {
 *   return a + b
 * }
 * ```
 */

any add(ttype GType, any a, any b) {
  //
  typecheck(GType, a);
  typecheck(GType, b);

  return a;
  //
}

// end //////////
int main(void);
int main(void) {
  // generics... HOW?

  // x := add[f64](22/7, 10/3)
  any x = add(f64, f64(22.0/7.0), f64(10.0/3.0));
  println("answer is {:?}", x);
  printf("hello sailor!");
  return 34 + 35;
}