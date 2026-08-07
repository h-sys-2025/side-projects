#ifndef ZASM_H
#define ZASM_H

/*
 * zasm – Tiny stack-based DSL for C
 * -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
 *
 * expected features:
 * ==================
 *   - push / pop / add / jmp / ret / halt
 *   - Temporary registers (ZTEMP(zaa) ...) auto-freed at END of scope
 *   - Nested scopes
 *   - Full call-stack with file:line (inportant)
 *   - Pretty crash dump on any runtime error (underflow, overflow, and more)
 *
 * see example.c and crash_demo.c (crash_demo.c is beta.)
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>

// some important+basic things.
#ifndef ZASM_STACK_SIZE
#  define ZASM_STACK_SIZE       256
#endif
#ifndef ZASM_CALL_STACK_SIZE
#  define ZASM_CALL_STACK_SIZE  64
#endif
#ifndef ZASM_MAX_TEMPS
#  define ZASM_MAX_TEMPS        64
#endif

// just in case, if they are not implemented!
typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int32_t  i32;

/* Runtime.
*/
typedef struct {
    const char *name;
    const char *file;
    int         line;
} zasm_frame_t;

typedef struct {
    u8              data_stack[ZASM_STACK_SIZE];
    int             sp;                 /* grows upward */

    zasm_frame_t    call_stack[ZASM_CALL_STACK_SIZE];
    int             csp;

    /* temporary register pool */
    u8             *temps[ZASM_MAX_TEMPS];
    int             temp_count;

    /* scope stack, how many temps belonged to each scope */
    int             scope_stack[ZASM_CALL_STACK_SIZE];
    int             scope_sp;
} zasm_vm_t;

extern zasm_vm_t zasm_vm;

/* Api: what programs will use.
*/
void zasm_init(void);
void zasm_crash(const char *fmt, ...) __attribute__((noreturn));
void zasm_print_call_stack(void);
void zasm_push_frame(const char *name, const char *file, int line);
void zasm_pop_frame(void);
void zasm_enter_scope(void);
void zasm_leave_scope(void);

/* Macros.
*/

/*
 * SCOPE / END
 *
 *   void foo(void) {
 *       SCOPE
 *           ZTEMP(zaa);
 *           ...
 *           ret;          // safe and it cleans up scope before returning
 *       END
 *   }
 */

#define SCOPE                                                           \
    do {                                                                \
        zasm_enter_scope();                                             \
        zasm_push_frame(__func__, __FILE__, __LINE__);                  \
        {

#define END                                                             \
        }                                                               \
        zasm_leave_scope();                                             \
        zasm_pop_frame();                                               \
    } while (0)

/* create a temporary data-register (automatickly auto-freed at end of current scope) */
#define ZTEMP(name)                                                     \
    u8 *name;                                                           \
    do {                                                                \
        if (zasm_vm.temp_count >= ZASM_MAX_TEMPS)                       \
            zasm_crash("too many temporary registers (max %d)",         \
                       ZASM_MAX_TEMPS);                                 \
        name = (u8 *)malloc(sizeof(u8));                                \
        if (!name) zasm_crash("out of memory for temporary");           \
        *name = 0;                                                      \
        zasm_vm.temps[zasm_vm.temp_count++] = name;                     \
    } while (0)

/* push value (auto u8) */
#define push(val)                                                       \
    do {                                                                \
        if (zasm_vm.sp >= ZASM_STACK_SIZE)                              \
            zasm_crash("data stack overflow on push");                  \
        zasm_vm.data_stack[zasm_vm.sp++] = (u8)(val);                   \
    } while (0)

/* pop into a u8 lvalue (or *temp) */
#define pop(dest)                                                       \
    do {                                                                \
        if (zasm_vm.sp <= 0)                                            \
            zasm_crash("data stack underflow on pop");                  \
        (dest) = zasm_vm.data_stack[--zasm_vm.sp];                      \
    } while (0)

/* add src into dst */
#define add(dst, src)                                                   \
    do {                                                                \
        (dst) = (u8)((u8)(dst) + (u8)(src));                            \
    } while (0)

/* jmp: C goto (for labels) or just call a function */
#define jmp(target)     goto target

/*
 * ret: leave current scope cleanly and return from the C function.
 * It must be used inside a SCOPE ... END pair.
 */
#define ret                                                             \
    do {                                                                \
        zasm_leave_scope();                                             \
        zasm_pop_frame();                                               \
        return;                                                         \
    } while (0)

/* halt */
#define halt            do { exit(0); } while (0)

/* call */
#define call(X) X()

/* documentary */
#define ENTRY(name)     /* entry point: name */
#endif /* ZASM_H */