module main

import os
import arrays

fn main() {
    data := os.read_file("./day3.data") or {
        eprintln(err)
        return
    }
    println(solve_day3_part2(data.split("\n")))
    return
}

//@ this solves day3 part2
fn solve_day3_part2(data []string) i64 {
    mut result := i64(0)

    for line in data {
        // Convert string to array of ints once
        digits := line.split("").map(it.int())

        // Greedily find the largest 12-digit number
        max_joltage := get_max_joltage(digits)
        result += max_joltage
    }
    return result
}

//@ helper for day3 part2
fn get_max_joltage(digits []int) i64 {
    k := 12
    mut result := i64(0)
    mut start_index := 0
    len := digits.len

    for i in 0 .. k {
        remaining_needed := k - 1 - i
        max_search_index := len - 1 - remaining_needed

        mut best_digit := -1
        mut best_index := start_index

        for j in start_index .. max_search_index + 1 {
            if digits[j] > best_digit {
                best_digit = digits[j]
                best_index = j
                if best_digit == 9 {
                    break
                }
            }
        }

        result = result * 10 + i64(best_digit)

        start_index = best_index + 1
    }

    return result
}

//@ this solves day3 part1 -- my programming skills += 10% (^_^)
fn solve_day3_part1(data []string) int {
    mut result := 0

    for line in data {
        mut possiblities := get_all_possiblities(line.split(""))
        // println(possiblities)
        max := arrays.max(possiblities) or {return result}
        result += int(max)
        // println(max)
    }

    return result
}

//@ helper for day3 part1
fn get_all_possiblities(nums []string) []i64 {
    mut possiblities := []i64{}

    for x in 0..nums.len {
        pairs := nums[x+1..nums.len]
        // println("num: ${num} | pairs: ${pairs}")
        for y in pairs {
            possiblities << "${nums[x]}${y}".int()
        }
    }

    return possiblities
}