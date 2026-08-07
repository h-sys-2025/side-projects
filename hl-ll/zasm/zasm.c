#include "zasm.h"

/* Global VM instance */
zasm_vm_t zasm_vm;

void zasm_init(void)
{
    memset(&zasm_vm, 0, sizeof(zasm_vm));
}

void zasm_push_frame(const char *name, const char *file, int line)
{
    if (zasm_vm.csp >= ZASM_CALL_STACK_SIZE)
        zasm_crash("critical: call stack overflow");
    zasm_vm.call_stack[zasm_vm.csp].name = name ? name : "<unknown>";
    zasm_vm.call_stack[zasm_vm.csp].file = file ? file : "<unknown>";
    zasm_vm.call_stack[zasm_vm.csp].line = line;
    zasm_vm.csp++;
}

void zasm_pop_frame(void)
{
    if (zasm_vm.csp > 0)
        zasm_vm.csp--;
}

void zasm_enter_scope(void)
{
    if (zasm_vm.scope_sp >= ZASM_CALL_STACK_SIZE)
        zasm_crash("critical: scope stack overflow");
    zasm_vm.scope_stack[zasm_vm.scope_sp++] = zasm_vm.temp_count;
}

void zasm_leave_scope(void)
{
    if (zasm_vm.scope_sp <= 0)
        return; /* already cleaned (e.g. by ret) */
    int base = zasm_vm.scope_stack[--zasm_vm.scope_sp];
    while (zasm_vm.temp_count > base) {
        --zasm_vm.temp_count;
        free(zasm_vm.temps[zasm_vm.temp_count]);
        zasm_vm.temps[zasm_vm.temp_count] = NULL;
    }
}

void zasm_print_call_stack(void)
{
    fprintf(stderr, "\ndump: call stack, caller first:\n");
    if (zasm_vm.csp == 0) {
        fprintf(stderr, "  (empty)\n");
    } else {
        /*
        for (int i = zasm_vm.csp - 1; i >= 0; --i) {
            const zasm_frame_t *f = &zasm_vm.call_stack[i];
            fprintf(stderr, "  #%d  %s()\n", zasm_vm.csp - 1 - i, f->name);
            fprintf(stderr, "       at %s:%d\n", f->file, f->line);
        }
        */
        for (int i = zasm_vm.csp - 1; i >= 0; --i) {
            const zasm_frame_t *f = &zasm_vm.call_stack[i];
            fprintf(stderr, "  #%d %s()", zasm_vm.csp - 1 - i, f->name);
            fprintf(stderr, " at %s:%d\n", f->file, f->line);
        }
    }

    /* data stack dump */
    fprintf(stderr, "dump: data stack (sp=%d): [", zasm_vm.sp);
    for (int i = 0; i < zasm_vm.sp; ++i) {
        fprintf(stderr, "%u%s", zasm_vm.data_stack[i],
                (i + 1 < zasm_vm.sp) ? ", " : "");
    }
    fprintf(stderr, "]\n");
    fprintf(stderr, "dump: live temporaries: %d\n", zasm_vm.temp_count);
}

void zasm_crash(const char *fmt, ...)
{
    fprintf(stderr, "\ncritical: runtime error: ");
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fprintf(stderr, "\n");
    zasm_print_call_stack();
    fprintf(stderr, "critical: aborting.\n");
    abort();
}