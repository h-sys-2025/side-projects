#include <stdio.h>
#include <stdint.h>

typedef enum { I64, I32, F64, F32, STRING } Type;

typedef struct {
    void* data;
    Type  type;
} Any;

#define _type(t) _type_##t

#define _type_I64   int64_t
#define _type_I32   int32_t
#define _type_F64   double
#define _type_F32   float
#define _type_STRING const char*

#define var(TYP, VAL) ({ \
    static __typeof__(VAL) _val_##__LINE__ = (VAL); \
    (Any){ .data = &_val_##__LINE__, .type = TYP }; \
})

#define cast(A, TYPE) (*(TYPE*)((A).data))

#define cast_any(A) _cast_any((A))
static inline double _cast_any(Any a) {   // returns double for simplicity, you can extend
    switch (a.type) {
        case I64: return (double)*(int64_t*)a.data;
        case I32: return (double)*(int32_t*)a.data;
        case F64: return *(double*)a.data;
        case F32: return (double)*(float*)a.data;
        default:  return 0.0;
    }
}

const char* type_name(Type t) {
    switch (t) {
        case I64:    return "i64";
        case I32:    return "i32";
        case F64:    return "f64";
        case F32:    return "f32";
        case STRING: return "char[]";
        default:     return "unknown";
    }
}

#define print_any(A) do { \
    Any _tmp = (A); \
    switch (_tmp.type) { \
        case I64: \
            printf("Type: %s, Value: %ld\n", type_name(_tmp.type), *(int64_t*)_tmp.data); \
            break; \
        case I32: \
            printf("Type: %s, Value: %d\n", type_name(_tmp.type), *(int32_t*)_tmp.data); \
            break; \
        case F64: \
            printf("Type: %s, Value: %f\n", type_name(_tmp.type), *(double*)_tmp.data); \
            break; \
        case F32: \
            printf("Type: %s, Value: %f\n", type_name(_tmp.type), *(float*)_tmp.data); \
            break; \
        case STRING: \
            printf("Type: %s, Value: %s\n", type_name(_tmp.type), (char*)_tmp.data); \
            break; \
        default: \
            printf("Type: unknown\n"); \
            break; \
    } \
} while(0)

Any add(Any a, Any b) {
    // For demo: promote everything to double
    double x = cast_any(a);
    double y = cast_any(b);
    static double result;
    result = x + y;
    return (Any){ .data = &result, .type = F64 };
}

int main(void) {
    Any pi   = var(F64, 22.0/7.0);
    Any count = var(I32, 42);
    Any big  = var(I64, 9000000000LL);
    Any name = var(STRING, "Violence");

    // print_any(pi);
    // print_any(count);
    // print_any(big);
    // print_any(name);

    _type(F64) d_val = cast(pi, _type(F64));
    _type(I32) i_val = cast(count, _type(I32));

    printf("\nCalculation: %f + 10 = %f\n", d_val, d_val + 10.0);

    Any sum = add(pi, count);
    print_any(sum);

    return 0;
}