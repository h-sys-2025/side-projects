module main

import os

fn main() {

    data := os.read_file("./samples/day3") or {
        eprintln(err)
        return
    }
    println(solve_day3_part1(data.split("\n")))
    return
}

//@ this solves day2 part2
fn solve_day3_part2(data []string) int {
    mut result := 0 // life support rating
    mut oxygen_generator_rating := 0
    mut CO2_scrubber_rating := 0

    //TBD

    result = oxygen_generator_rating * CO2_scrubber_rating
    return result
}

//@ this solves day2 part1
fn solve_day3_part1(data []string) i64 {
    mut result := i64(0) // power consumption

    mut gemma_rate    := ""
    mut epsilion_rate := ""

    for x in 0..data[0].len {
        mut line := ""
        for y in 0..data.len {
            yy := data[y].split("")[x]
            line = "${line}${yy}"
        }
        // println("line: ${line} | ${count(line)}")
        mut la_gemma_rate    := count(line)
        mut la_epsilion_rate := "1"
        if la_gemma_rate == "1" {
            la_epsilion_rate = "0"
        }
        gemma_rate = "${gemma_rate}${la_gemma_rate.str()}"
        epsilion_rate = "${epsilion_rate}${la_epsilion_rate.str()}"
    }
    println("${gemma_rate}/${epsilion_rate}\n\n")
    g_rate := gemma_rate.parse_int(2, 64) or {
        eprintln(err)
        return 0
    }
    e_rate := epsilion_rate.parse_int(2, 64) or {
        eprintln(err)
        return 0
    }

    result = g_rate * e_rate

    return result
}

//@ helper
fn count(data string) string {
    mut zero := 0

    for x in data.split("") {
        if x.int() == 0 {
            zero += 1
        }
    }

    if zero > data.len-zero {
        return "0"
    } else {
        return "1"
    }

    return ""
}