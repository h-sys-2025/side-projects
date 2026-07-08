module main

fn main() {
    roman_text := "XVII"
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
     */

     println("roman: ${roman_text} to int is ${roman_to_int_voila(roman_text)}")

    return
}

fn roman_to_int_voila(roman_text string) int {
    mut summmm := 0
    for whatever in roman_text.to_lower().split("").reverse() {
        if whatever == "i" {
            summmm += 1
        } else if whatever == "v" {
            summmm += 5
        } else if whatever == "x" {
            summmm += 10
        } else {
            eprintln("NUMERAL ${whatever} is not supported yeat!")
            return 0
        }
    }
    return summmm
}