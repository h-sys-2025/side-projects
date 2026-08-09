/*

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
*/

#include "zasm.h"
#include <stdio.h>

/* Add 4 numbers.
*/
void add_4_numbers(void)
{
    SCOPE
        /* declaring tempraries for allocation.
        */
        ZTEMP(zaa);
        ZTEMP(zab);
        ZTEMP(zac);
        ZTEMP(zad);

        /* popping values into predefined temporaries registers.
        */
        pop(*zaa);
        pop(*zab);
        pop(*zac);
        pop(*zad);

        /* perform add.
        */
        add(*zaa, *zab);
        add(*zaa, *zac);
        add(*zaa, *zad);

        /* push return value */
        push(*zaa);

        ret;
    END;
}

/* Main function.
*/
int main(void)
{
    zasm_init();

    ENTRY(main)

    SCOPE
        /* push 4 arguments */
        push(1);
        push(2);
        push(3);
        push(4);

        /* call the “function” */
        call(add_4_numbers);

        {
            u8 result;
            pop(result);
            printf("Result of 1+2+3+4 = %u\n", result);
        }

        push(0);            /* exit code */
    END;

    halt;
    return 0;
}