/*
 * Demonstrates the pretty call-stack dump on a runtime error.
 * Intentionally underflows the data stack.
 */

#include "zasm.h"

/*
level3:
%scope
  pop zaa
  ret
%end
*/
void level3(void)
{
    SCOPE
        ZTEMP(zaa);
        pop(*zaa);          /* it will crash here (because the stack is empty) */
        ret;
    END;
}

/*
level2:
%scope
  jmp level3
  ret
%end
*/
void level2(void)
{
    SCOPE
        level3();
        ret;
    END;
}


/*
level1:
%scope
  jmp level2
  ret
%end
*/
void level1(void)
{
    SCOPE
        level2();
        ret;
    END;
}


/*
%entry main
%scope
  jmp level1
  ret
%end

halt
*/
int main(void)
{
    zasm_init();

    SCOPE
        /* push nothing and force underflow */
        level1();
    END;

    halt;
    return 0;
}