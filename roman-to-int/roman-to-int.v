module main

fn main() {
    mut roman_text := map[string]int
    roman_text["X"] = 10
    roman_text["XVII"] = 17
    roman_text["XII"] = 12
    roman_text["XIV"] = 14
    roman_text["IV"] = 4

    for k,v in roman_text {
        q := roman_to_int_voila(k)
        if q == v {
            println("passed: ${k} == ${q}")
        } else {
            println("failed: ${k} != ${q} (was supposted to be ${v})")
        }
    }
    /* thinking:
     *
     * 1. XVII (becomes) IIVX
     *
     * 2. I (sum is 1)
     *
     * 3. (again) I (sum is 2)
     *
     * 4. V (add 2 to 5, sum is 7)
     *
     * 5. X (add 10 to 8, sun is 17)
     *
     * 6. if last > current, then -current!
     */

    return
}

fn roman_to_int_voila(roman_text string) int {
    mut summmm := 0
    mut last := 0
    for whatever in roman_text.to_lower().split("").reverse() {
        if whatever == "i" {
            if last > 1 {
                summmm -= 1
            } else {
                summmm += 1
            }
            last = 1
        } else if whatever == "v" {
            if last > 5 {
                summmm -= 5
            } else {
                summmm += 5
            }
            last = 5
        } else if whatever == "x" {
            if last > 10 {
                summmm -= 10
            } else {
                summmm += 10
            }
            last = 10
        } else {
            eprintln("NUMERAL ${whatever} is not supported yeat!")
            return 0
        }
    }
    return summmm
}