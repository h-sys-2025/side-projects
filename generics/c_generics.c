#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

typedef enum { I64, I32, F64, F32, STRING } Type;

typedef struct {
    const void* data;   // Changed to const void*
    Type type;
} Any;

#define _type(t) _type_##t

#define _type_I64   int64_t
#define _type_I32   int32_t
#define _type_F64   double
#define _type_F32   float
#define _type_STRING const char*

#define var(TYP, VAL) _VAR_IMPL(TYP, VAL, __COUNTER__)

#define _VAR_IMPL(TYP, VAL, CNT) ({ \
    __typeof__(VAL) _val_##CNT = (VAL); \
    (Any){ .data = (const void*)&_val_##CNT, .type = TYP }; \
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


// function using type `Any`.
Any add(Any a, Any b) {
    // For demo: promote everything to double
    double x = cast_any(a);
    double y = cast_any(b);
    static double result;
    result = x + y;
    return (Any){ .data = &result, .type = F64 };
}

// raw skell-iton of generics //

#define PANIC(...) fprintf(stderr, "PANIC: %s:%d - %s\n", __FILE__, __LINE__, __VA_ARGS__);

#define type_check(A,B) if ((A).type != (B).type) { PANIC("type_check: runtime type-mismatch!"); }
#define type_check_abort(A,B) if ((A).type != (B).type) { PANIC("type_check: runtime type-mismatch!"); abort(); }

#define type(A) (A).type

//--//

// this is hard, I will continue sometime later! (I hope)
Any mult(Any a, Any b) {
    // test: type_check_abort(a, b);
    type_check(a, b); // just tell the user that he did something wrong!
    double x = cast_any(a);
    double y = cast_any(b);
    static double result;
    result = x * y;
    return (Any){ .data = &result, .type = type(a) };
}

// more things //

#define fn(X) (Any aargs[X])
#define ret(...) (Any){__VA_ARGS__}
#define init_args(X) int32_t ttop = (X); (void)ttop; /* int32_t mmax = (X); */

Any shift_args(Any argv[], int32_t argc) {
    assert(argc > 0 && "Cannot shift from empty list");

    Any elem = argv[argc];
    return elem;         // Return the saved element
}

#define shift shift_args(aargs, ttop); ttop--;

Any addittion fn(2) {
    init_args(2);
    Any x = shift;
    Any y = shift;

    static double xx, yy;
    xx = cast_any(x);
    yy = cast_any(y);

    const double zz = xx + yy;

    return var(F64, zz);
}

#define call(X,...) X([__VA_ARGS__]);

//--//

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

    printf("\nCalculation: %f + %d = %f\n", d_val, i_val, d_val + i_val );

    Any sum = add(pi, count);
    print_any(sum);

    Any some = mult(pi,count);
    print_any(some);

    //Any whatever = call(divide, sum, some);
    Any la_list[2];
    la_list[0] = var(F64, 1000);
    la_list[1] = var(F64, 3);
    Any whatever2 = addittion(la_list);

    print_any(whatever2);

    return 0;
}