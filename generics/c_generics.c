#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

typedef enum { I64, I32, F64, F32, STRING } Type;

typedef struct {
    const void* data;
    Type type;
} Any;

#define _type(t) _type_##t
#define _type_I64 int64_t
#define _type_I32 int32_t
#define _type_F64 double
#define _type_F32 float
#define _type_STRING const char*

#define var(TYP, VAL) _VAR_IMPL(TYP, VAL, __COUNTER__)
#define _VAR_IMPL(TYP, VAL, CNT) ({ \
    __typeof__(VAL) _val_##CNT = (VAL); \
    (Any){ .data = (const void*)&_val_##CNT, .type = TYP }; \
})

#define cast(A, TYPE) (*(TYPE*)((A).data))

static inline double _cast_any(Any a) {
    switch (a.type) {
        case I64: return (double)*(int64_t*)a.data;
        case I32: return (double)*(int32_t*)a.data;
        case F64: return *(double*)a.data;
        case F32: return (double)*(float*)a.data;
        default: return 0.0;
    }
}
#define cast_any(A) _cast_any(A)

const char* type_name(Type t) {
    switch (t) {
        case I64: return "i64";
        case I32: return "i32";
        case F64: return "f64";
        case F32: return "f32";
        case STRING: return "char[]";
        default: return "unknown";
    }
}

#define print_any(A) do { \
    Any _tmp = (A); \
    switch (_tmp.type) { \
        case I64: printf("Type: %s, Value: %ld\n", type_name(_tmp.type), *(int64_t*)_tmp.data); break; \
        case I32: printf("Type: %s, Value: %d\n",  type_name(_tmp.type), *(int32_t*)_tmp.data); break; \
        case F64: printf("Type: %s, Value: %f\n",  type_name(_tmp.type), *(double*)_tmp.data); break; \
        case F32: printf("Type: %s, Value: %f\n",  type_name(_tmp.type), *(float*)_tmp.data); break; \
        case STRING: printf("Type: %s, Value: %s\n", type_name(_tmp.type), (char*)_tmp.data); break; \
        default: printf("Type: unknown\n"); break; \
    } \
} while(0)

// ===================================================================

Any add(Any a, Any b) {
    double x = cast_any(a);
    double y = cast_any(b);
    static double result;
    result = x + y;
    return (Any){ .data = &result, .type = F64 };
}

Any mult(Any a, Any b) {
    double x = cast_any(a);
    double y = cast_any(b);
    static double result;
    result = x * y;
    return (Any){ .data = &result, .type = F64 };
}

// Args things

#define fn(X) (Any aargs[X])
#define init_args(X) int32_t ttop = (X)

Any shift_args(Any argv[], int32_t* ptop) {
    assert(*ptop > 0 && "Cannot shift from empty list");
    Any elem = argv[*ptop - 1];   // Fixed indexing
    (*ptop)--;
    return elem;
}

#define shift shift_args(aargs, &ttop)

// Basic Example Usage

Any divide fn(2) {
    init_args(2);
    Any y = shift;   // last argument first (stack-like)
    Any x = shift;

    double xx = cast_any(x);
    double yy = cast_any(y);
    const double zz = xx / yy;

    return var(F64, zz);
}

// ===================================================================

#define call(X, ...) X((Any[]){__VA_ARGS__});

int main(void) {
    Any pi = var(F64, 22.0/7.0);
    Any count = var(I32, 42);

    _type(F64) d_val = cast(pi, _type(F64));
    _type(I32) i_val = cast(count, _type(I32));

    printf("\nCalculation: %f + %d = %f\n", d_val, i_val, d_val + i_val);

    Any sum = add(pi, count);
    print_any(sum);

    Any some = mult(pi, count);
    print_any(some);

    Any la_list[2];
    la_list[0] = var(F64, 1000.0);
    la_list[1] = var(F64, 3.0);

    printf("\ndivide:\n");
    // Any whatever2 = divide(la_list);
    // Any whatever2 = call(divide, la_list);
    Any whatever = divide((Any[]){
        var(F64, 1000.0),
        var(F64, 3.0)
    });

    Any whatever2 = call(divide, var(F64, 1000.0), var(F64, 3.0));
    print_any(whatever2);

    return 0;
}