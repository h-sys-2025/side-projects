/*

    Today I woke up and choose violence!

    # Implement generics in pure c99.
    - Just for fun. (recreational-programming)
    ## Rules:
    1. dont use macros.
    2. dont make it repetitive.

*/
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

typedef enum { i64, i32, f64, f32 } typetype;

typedef struct {
    void* data;
    typetype type;
} any;

#define var(TYP, VAL) ({ \
    static __typeof__(VAL) _val_##__LINE__ = (VAL); \
    (any){ .data = &_val_##__LINE__, .type = TYP }; \
})

typetype type(any variable) {
    return variable.type;
}
const char* typec(any variable) {
    switch (variable.type) {
        case i64: return "i64";
        case i32: return "i32";
        case f64: return "f64";
        case f32: return "f32";
        default:  return "unknown";
    }
}


int main() {
    any pi = var(f64, 22.0/7.0);
    any count = var(i32, 42);

    // Print type name and value
    printf("Type: %s, Value: %f\n", typec(pi), *(double*)pi.data);
    printf("Type: %s, Value: %d\n", typec(count), *(int*)count.data);

    return 0;
}