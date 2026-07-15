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

typedef enum { i64, i32, f64, f32, string } typetype;

typedef struct {
    void* data;
    typetype type;
} any;

#define var(TYP, VAL) ({ \
    static __typeof__(VAL) _val_##__LINE__ = (VAL); \
    (any){ .data = &_val_##__LINE__, .type = TYP }; \
})

const char* typen(typetype t) {
    switch (t) {
        case i64: return "i64";
        case i32: return "i32";
        case f64: return "f64";
        case f32: return "f32";
        case string: return "char[]";
        default:  return "unknown";
    }
}

// A simple macro to cast `void*` to the required type, using enum.
// returns the value (not a pointer) yayyy!
#define cast_any(A) ({ \
    __typeof__(0) _res; \
    any _tmp = (A); \
    switch (_tmp.type) { \
        case i64:  _res = *(int64_t*)_tmp.data; break; \
        case i32:  _res = *(int32_t*)_tmp.data; break; \
        case f64:  _res = *(double*)_tmp.data; break; \
        case f32:  _res = *(float*)_tmp.data; break; \
        default:   _res = 0; break; \
    } \
    _res; \
})

// since a macro cannot change its return type (it's either int or a double or whatever.),
// you usually cast to a specific type you want, or use a helper block (maybe).
// if you want to print it directly, you can use the print_any() macro!

// generic printer macro
#define print_any(A) ({ \
    any _tmp = (A); \
    switch (_tmp.type) { \
        case i64:  printf("Type: %s, Value: %ld\n", typen(_tmp.type), *(int64_t*)_tmp.data); break; \
        case i32:  printf("Type: %s, Value: %d\n", typen(_tmp.type), *(int32_t*)_tmp.data); break; \
        case f64:  printf("Type: %s, Value: %f\n", typen(_tmp.type), *(double*)_tmp.data); break; \
        case f32:  printf("Type: %s, Value: %f\n", typen(_tmp.type), *(float*)_tmp.data); break; \
        default:   printf("Type: unknown\n"); break; \
    } \
})

#define cast_any_as(A, TYPE) (*(TYPE*)((A).data))

int main() {

    any pi = var(f64, 22.0/7.0);
    any count = var(i32, 42);
    any big = var(i64, 9000000000LL);

    print_any(pi);
    print_any(count);
    print_any(big);

    // get the value for math, we must say the type we want!
    double d_val = cast_any(pi);
    int i_val = cast_any_as(count, int);

    printf("Calculation: %f + 10 = %f\n", d_val, d_val + 10.0);

    return 0;
}