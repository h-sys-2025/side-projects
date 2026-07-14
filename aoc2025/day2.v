module main

import os
import strings

fn main() {
    data := os.read_file("./day2.data") or {
        eprintln('Failed to read file: ${err}')
        return
    }

    if data.len == 0 {
        eprintln("Error: File is empty!")
        return
    }

    println(solve_day2_part2(data))
}

// Checks if a string is composed of a repeated substring (Part 2 logic)
fn is_invalid(id_str string) bool {
    len := id_str.len
    if len == 0 {
        return false
    }

    // Try all possible substring lengths (divisors of len)
    // The pattern length 'l' must be at most len/2 to repeat at least twice
    for l in 1 .. len/2 + 1 {
        if len % l == 0 {
            pattern := id_str[..l]
            // Construct the repeated string
            mut constructed := strings.repeat_string(pattern, len/l)
            if constructed == id_str {
                return true
            }
        }
    }
    return false
}

fn solve_day2_part2(data string) i64 {
    mut result := i64(0)

    // Remove newlines and split by comma
    normalized_data := data.replace("\n", "").replace("\r", "")
    lines := normalized_data.split(",")

    for line in lines {
        trimmed := line.trim_space()
        if trimmed.len == 0 {
            continue
        }

        parts := trimmed.split('-')
        if parts.len != 2 {
            eprintln('Skipping malformed line: "${trimmed}"')
            continue
        }

        start := parts[0].i64()
        end := parts[1].i64()

        // Iterate through the range (inclusive)
        for num in start .. end + 1 {
            s := num.str()
            if is_invalid(s) {
                result += num
                // Optional: Debug specific matches
                // println('${num} is invalid!')
            }
        }
    }

    return result
}