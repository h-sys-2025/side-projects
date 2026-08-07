## Lasm (or Zasm), high-level low-level code.
- I want to learn assembly, but assambly is hard!
- So why not create custom form of assembly? (more) with stack-trace when runtime-error happens? yes!!.

### Examples:
```asm
add_4_numbers:
%scope
  ; pop arguments.
  pop zaa ; all registers starting with zXX are temprary, and are auto-freed when %scope ends.
  pop zab
  pop zac
  pop zad ; if any of the pop fails, it will throw a runtime error with full stack trace.

  ; add numbers.
  add zaa, zab
  add zaa, zac
  add zaa, zad ; answer is in zaa

  ; push return argument.
  push zaa

  ; return to caller location.
  ret
%end

%entry main
%scope
  ; push 4 arguments for function add_4_numbers.
  push 1 ; all numbers are auto inferred to their type, in this case, they are u8.
  push 2
  push 3
  push 4
  ; jump to that function.
  jmp add_4_numbers ; small trick of calling functions without defineing functions.

  push 0
  ; return with exit code 0
  ret
%end

halt
```
- Implemented in `./zasm/example.c`