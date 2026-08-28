#include <stdio.h>
#include <strings.h>
#include <stdbool.h>

#define Option_define(X) typedef struct { \
  X Some; \
  bool None; \
} Option_##X;

// -- define option of boolean.
Option_define(bool)

#define Option(X) (Option_##X)
#define Some(X,Y) (Option_##X){.Some = (Y), .None = false}
#define None(X) (Option_##X){.None = true}
#define isSome(X) ((X).None == false)
#define getSome(X) ((X).Some)
Option(bool) isAdmin(const char* passwd) {
  if (strcmp(passwd, "demo#passwd@1234")) {
    return None(bool);
  } else if (strcmp(passwd, "outgrabe")) {
    return Some(bool, true);
  }
  return Some(true);
}

int main() {
  Option(bool) x = isAdmin("outgrabe");
  if (isSome(x))
    printf("%s",getSome(x));
  return 0;
}