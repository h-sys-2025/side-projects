/*
 * control_jit.c: some sort of template JIT with (almost) full control flow.
 *   for -- if / else -- while -- labels / goto
 *   and some extra optimisations (aligned entry, raw reg use (for loops: i and s), kindof dense loops)
 *
 * To demonstrates how the JIT compiler emits native jumps for every control construct.
 *
 * To build: gcc -O3 -o jit1 control_basic_jit.c
 * To run:   ./jit1

_*_ Running: `gcc -Wall -Wextra /.../side-projects/JIT-compilers/control_basic_jit.c -o /tmp/gotermx_run && /tmp/gotermx_run` _*_


sum_to(1,000,000,000) = 499999999500000000
abs(-42) = 42
abs(42)  = 42
time taken to sum 1billion numbers: 317.67 ms
running sum_to(1,000,000,000) 200 times --- JIT for-loop : 6286.70 ms  (result 999999990000000000)

Process completed with exit code: 0

 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>

typedef int64_t (*Fn)(int64_t);

uint8_t *code;
size_t code_len, code_cap = 1 << 18;

void emit(const void *p, size_t n) {
  if (code_len + n > code_cap) { fprintf(stderr,"overflow\n"); exit(1); }
  typeof(code+code_len) u1 = code + code_len;
  memcpy(u1, p, n);
  code_len = code_len + n;
}
void e8(uint8_t b)  { emit(&b,1); }
void e32(uint32_t v){ emit(&v,4); }

/* smalll and simple label/patch system */
typedef struct { const char *name; size_t offset; } Label;
typedef struct { size_t at; const char *target; int is_jl; uint8_t cc; } Patch;

// some global things. (temporary, not untill, I make a full JIT, they might change in actual mj source)
Label  labels[64];
int    nlabels;
Patch  patches[128];
int    npatches;

// helper for defining labels!
void llabel(const char *name) {
  labels[nlabels++] = (Label){name, code_len};
}

void jmp(const char *target) {
  patches[npatches++] = (Patch){code_len, target, 0, 0};
  e8(0xe9); e32(0); // jmp rel32
}

void jl(uint8_t cc, const char *target) {
  patches[npatches++] = (Patch){code_len, target, 1, cc};
  e8(0x0f); e8(cc); e32(0); // jl rel32
}

void patch_all(/*size_t base*/) {
  for (int i = 0; i < npatches; i++) {
    size_t target = 0;
    for (int j = 0; j < nlabels; j++)
      if (!strcmp(labels[j].name, patches[i].target)) {
        target = labels[j].offset;
        break;
      }
    int32_t rel;
    if (patches[i].is_jl) {
      rel = (int32_t)(target - (patches[i].at + 6));
      memcpy(code + patches[i].at + 2, &rel, 4);
    } else {
      rel = (int32_t)(target - (patches[i].at + 5));
      memcpy(code + patches[i].at + 1, &rel, 4);
    }
  }
}

/*
 * A super-simple example program to test JIT emission.
 *
 *   // this is what it looks like in mj.
 *   fun sum_to(n) {
 *     var s = 0;
 *     for (var i = 0; i < n; i = i + 1) {
 *       s = s + i;
 *     }
 *     return s;
 *   }
 */
static Fn emit_sum_to(void) {
  nlabels = npatches = 0;
  while (code_len & 15) e8(0x90); /* align */
  size_t start = code_len;

  /* rdi = n
     Lets use these like LuaJIT:
       rbx = n (callee is this)
       rcx = i // this is reserved for loop variable, and cannot be used fro any other usecase.
       rax = s // this is our limit.
  */

  // loop initlizing.
  e8(0x53);                               /* push rbx */
  e8(0x48); e8(0x89); e8(0xfb);           /* mov rbx, rdi   ; n */

  // ZERO rax and rcx registers.
  e8(0x48); e8(0x31); e8(0xc0);           /* xor rax, rax   ; s = 0 */
  e8(0x48); e8(0x31); e8(0xc9);           /* xor rcx, rcx   ; i = 0 */

  // this is where our loop will jump.
  llabel("loop");

  /* if (i >= n) goto done */
  e8(0x48); e8(0x39); e8(0xd9);           /* cmp rcx, rbx */
  jl(0x8d, "done");                      /* jge done */

  /* s += i */
  e8(0x48); e8(0x01); e8(0xc8);           /* add rax, rcx */
  /* i += 1 */
  e8(0x48); e8(0xff); e8(0xc1);           /* inc rcx */
  jmp("loop");                            /* goto loop */

  // this is emd of our program, here we close our program and halt.
  llabel("done");
  e8(0x5b);                               /* pop rbx */
  e8(0xc3);                               /* ret */

  patch_all(start);
  return (Fn)(code + start);
}

/*
 * One more example: to demonstrafe if/else/goto (this one is buggy and slow)
 *   // mj code.
 *   fun abs(x) {
 *     if (x < 0) goto neg;
 *     return x;
 *   neg:
 *     return -x;
 *   }
 */
static Fn emit_abs(void) {
  nlabels = npatches = 0;
  while (code_len & 15) e8(0x90);
  size_t start = code_len;

  // cmp rdi, 0
  e8(0x48); e8(0x83); e8(0xff); e8(0x00);
  jl(0x8c, "neg");                        /* jl neg */

  // return x
  e8(0x48); e8(0x89); e8(0xf8);           /* mov rax, rdi */
  e8(0xc3);

  llabel("neg");
  e8(0x48); e8(0x89); e8(0xf8);           /* mov rax, rdi */
  e8(0x48); e8(0xf7); e8(0xd8);           /* neg rax */
  e8(0xc3);

  patch_all(start);
  return (Fn)(code + start);
}

double now_ms(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (
    (ts.tv_sec * 1e3)
    +
    (ts.tv_nsec * 1e-6) // math is hard.
  );
}

int main(void) {
  // use with caution.
  code = mmap(NULL, code_cap, PROT_READ|PROT_WRITE|PROT_EXEC,
              MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);

  if (code == MAP_FAILED) {
    perror("mmap");
    return 1;
  }

  // ok, here we go.
  Fn sum_to = emit_sum_to();
  Fn absfn  = emit_abs();

  // correctness benchmrk
  double t0 = now_ms();
  printf("sum_to(1,000,000,000) = %lld \n", (long long)sum_to(1000000000));
  printf("abs(-42) = %lld\n", (long long)absfn(-42));
  printf("abs(42)  = %lld\n", (long long)absfn(42));
  double t = now_ms() - t0;
  printf("time taken to sum 1billion numbers: %.2f ms", t);

  // speed-comparison: for-loop style sum, this is very slow!.
  t0 = now_ms();
  int64_t r = 0;
  for (int i = 0; i < 200; i++) r += sum_to(100000000);
  t = now_ms() - t0;
  printf("\nrunning sum_to(1,000,000,000) 200 times --- JIT for-loop : %.2f ms  (result %lld)\n", t, (long long)r);

  return 0;
}