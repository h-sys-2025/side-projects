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
    ttype _type;
    union {
        int32_t  i32;
        int64_t  i64;
        uint32_t u32;
        uint64_t u64;
        float    f32;
        double   f64;
    } value;
} any_t;
#define any any_t

// macros for casts or whatever //
#define to_f64(X) (any_t){._type = f64, .value.f64 = (X)}
#define to_f32(X) (any_t){._type = f32, .value.f32 = (X)}
#define to_u32(X) (any_t){._type = u32, .value.u32 = (X)}
#define to_u64(X) (any_t){._type = u64, .value.u64 = (X)}
#define to_i32(X) (any_t){._type = i32, .value.i32 = (X)}
#define to_i64(X) (any_t){._type = i64, .value.i64 = (X)}
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

        size_t token_len = (end) ? (size_t)(end - start) : strlen(start);

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

#define println(X,...) pprintln((X),(any[]){__VA_ARGS__})
void pprintln(const char* format, any items[]) {
    if (!format) return;

    char** parts = split_string(format, DELIM);
    if (!parts) return;

    // Count actual number of items passed (aura++)
    size_t item_count = 0;
    if (items) {
        while (item_count < 32) {  // reasonable upper limit
            if (items[item_count]._type == 0 && item_count > 0) break;
            item_count++;
        }
    }

    size_t item_idx = 0;

    for (size_t i = 0; parts[i] != NULL; i++) {
        printf("%s", parts[i]);

        // Replace {:?} with next item
        if (item_idx < item_count && parts[i+1] != NULL) {  // only if there's more parts
            any item = items[item_idx];

            switch (item._type) {
                case i32: printf("%d",   item.value.i32); break;
                case i64: printf("%ld",  item.value.i64); break;
                case u32: printf("%u",   item.value.u32); break;
                case u64: printf("%lu",  item.value.u64); break;
                case f32: printf("%f",   item.value.f32); break;
                case f64: printf("%f",   item.value.f64); break;
                default:  printf("<unknown>");
            }
            item_idx++;
        }
    }

    printf("\n");
    free_split(parts);
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
  typecheck(GType, a);
  typecheck(GType, b);

  any result = {._type = GType};

  switch (GType) {
    case f64:
      result.value.f64 = a.value.f64 + b.value.f64;
      break;
    // Add more types later...
    default:
      printf("add not implemented for type %s\n", repr(GType));
      abort();
  }
  return result;
}

// end //////////
int main(void);
int main(void) {
  any x = add(f64, to_f64(35.1), to_f64(33.9));
  println("answer is {:?}", x);
  println("hello sailor! pi is approx {:?}", to_f64(22.0/7.0));
  return 0;
}