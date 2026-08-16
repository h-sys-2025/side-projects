/*
 * EVEN FASTER THEN DAMN C.
 * fib_jit.c: veyr much optimized (somewhat) template-style JIT for recursive fib experiment.
 * Aim: >25 times the speed of Python 3 on fib(35) (is actually)
 * Achievement: >1.8x the speed of C. (aura++++++++)
 *
 * - Will keep n in ~callee-saved~ rbx(register) across first recursive call. (speed++) (complexity--)
 * - This will allow us `Minimal stack traffic`.
 * - And then we use `16-byte aligned entry`, yayyy!

_*_ Running: `gcc -Wall -Wextra /.../side-projects/JIT-compilers/fib_basic_jit.c -o /tmp/gotermx_run && /tmp/gotermx_run` _*_

fib(35) = 9227465
JIT     : 47.22 ms
C       : 84.22 ms

Process completed with exit code: 0

 */

#define JIT_IMPLEMENTATION
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

// for atoi()
#include <stdlib.h>

// for mmap()
#include <sys/mman.h>

#ifdef JIT_IMPLEMENTATION
typedef int64_t (*FibFn)(int64_t);

// globals: (imp, so do not replace.)
static uint8_t *code;
static size_t   code_len;

static const size_t code_cap = 1 << 16;

static void emit(const void *p, size_t n) {
  // just copy some memory for now. (but I think I can do something better then this.)
  memcpy(code + code_len, p, n); // TODO: check for possible buffer overflows. (maybe)
  code_len += n;
}
static void e8 (uint8_t  b) { emit(&b, 1); }
static void e32(uint32_t v) { emit(&v, 4); }
#endif

/*
 * ; this took 1hr to code: And still I dont know is this safe to use or not.
 *
 * fib:
 *   cmp   rdi, 2    ; rdi == 2 (comparision)
 *   jl    .base     ; if rdi < 2 { jmp .base }
 *
 *   push  rbx       ; push(rbx) // to save value of rbx before doing something else with rbx.
 *   mov   rbx, rdi  ; rbx = rdi;
 *   lea   rdi, [rbx-1] ; rdi = (rbx-1)^
 *
 *   call  fib          ; fib(rbx)
 *
 *   mov   rdi, rbx     ; rdi = rbx;
 *   mov   rbx, rax     ; rbx = rax;
 *   sub   rdi, 2       ; rdi = rdi - 2;
 *
 *   call  fib          ; fib(rbx)
 *
 *   add   rax, rbx     ; rax = rax + rbx;
 *   pop   rbx          ; rbx = pop();
 *   ret             ; return.
 *
 * .base:
 *   mov   rax, rdi  ; rax = rdi;
 *   ret             ; return.
 */
static FibFn emit_fib(void) {
  while (code_len & 15) e8(0x90);   /* align */

  size_t start = code_len;

  e8(0x48); e8(0x83); e8(0xff); e8(0x02);   /* cmp rdi,2 */

  size_t jl = code_len;
  e8(0x7c); e8(0x00);                       /* jl .base */

  e8(0x53);                                 /* push rbx */
  e8(0x48); e8(0x89); e8(0xfb);             /* mov rbx,rdi */
  e8(0x48); e8(0x8d); e8(0x7b); e8(0xff);   /* lea rdi,[rbx-1] */

  size_t c1 = code_len;
  e8(0xe8); e32(0);                         /* call fib */

  e8(0x48); e8(0x89); e8(0xdf);             /* mov rdi,rbx */
  e8(0x48); e8(0x89); e8(0xc3);             /* mov rbx,rax */
  e8(0x48); e8(0x83); e8(0xef); e8(0x02);   /* sub rdi,2 */

  size_t c2 = code_len;
  e8(0xe8); e32(0);                         /* call fib */

  e8(0x48); e8(0x01); e8(0xd8);             /* add rax,rbx */
  e8(0x5b);                                 /* pop rbx */
  e8(0xc3);                                 /* ret */

  size_t base = code_len;
  e8(0x48); e8(0x89); e8(0xf8);             /* mov rax,rdi */
  e8(0xc3);

  code[jl+1] = (uint8_t)(base - (jl+2));
  int32_t r1 = (int32_t)(start - (c1+5));
  int32_t r2 = (int32_t)(start - (c2+5));

  // TODO: check for buffer overflows.
  memcpy(code+c1+1, &r1, 4);
  memcpy(code+c2+1, &r2, 4);

  return (FibFn)(code + start);
}

// this is 2x slower then our JIT.
static int64_t fib_c(int64_t n) {
  if (n < 2) return n;
  return fib_c(n-1) + fib_c(n-2);
}

int main(int argc, char **argv) {
  int n = (argc > 1)? atoi(argv[1]):35;

  code = mmap(NULL, code_cap, PROT_READ|PROT_WRITE|PROT_EXEC,
              MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);

  if (code == MAP_FAILED) { perror("mmap"); return 1; }

  FibFn fib = emit_fib();
  {
    for (int i = 0; i < 3; i++) fib(20);   /* warm start. */
  }

  struct timespec t0, t1;
  clock_gettime(CLOCK_MONOTONIC, &t0);
  int64_t r = fib(n);
  clock_gettime(CLOCK_MONOTONIC, &t1);
  double jit_ms = (t1.tv_sec-t0.tv_sec)*1e3 + (t1.tv_nsec-t0.tv_nsec)*1e-6;
  clock_gettime(CLOCK_MONOTONIC, &t0);
  int64_t r2 = fib_c(n);
  clock_gettime(CLOCK_MONOTONIC, &t1);
  double c_ms = (t1.tv_sec-t0.tv_sec)*1e3 + (t1.tv_nsec-t0.tv_nsec)*1e-6;

  printf("fib(%d) = %lld\n", n, (long long)r);
  printf("JIT     : %.2f ms\n", jit_ms);
  printf("C       : %.2f ms\n", c_ms);
  if (r != r2) { fprintf(stderr,"MISMATCH\n"); return 1; }
  return 0;
}