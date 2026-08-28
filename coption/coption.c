#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#define concat_lvl_2_macro_expansion_because_macros_are_not_that_powerfull_and_safe_to_use(A, B) A##B
#define concat(A, B) concat_lvl_2_macro_expansion_because_macros_are_not_that_powerfull_and_safe_to_use(A, B)

#define Option_define(s) typedef struct { \
  s Some; \
  bool None; \
} concat(Option_, s);

// -- define option of bool type.
Option_define(bool)

#define Option(s) concat(Option_, s)
#define Some(s,Y) (Option(s)){.Some = (Y), .None = false}
#define None(s,Y) (Option(s)){.None = true}
#define isSome(s) (s.None == false)
#define getSome(s) (s.Some)

// --- usage ---

Option(bool) isAdmin(const char* passwd) {
    if (strcmp(passwd, "demo#passwd@1234") == 0) {
        return None(bool, false);
    } else if (strcmp(passwd, "outgrabe") == 0) {
        return Some(bool, true);
    }
    return Some(bool, false);
}

int main() {
    Option(bool) x = isAdmin("outgrabe");
    if (isSome(x)) {
        printf("%d\n", getSome(x));
    }
    return 0;
}