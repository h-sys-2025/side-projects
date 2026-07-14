module main

import math
import os

fn main() {
    // test:
    // println(
    // finite_field_move(
    // 256,
    // 45,
    // 573
    // )
    // )

    // right = +ve
    // left  = -ve

    // yep, it works: println(finite_field_move(100,0,-1)) // should print 99
    init_pos := 50
    limit := 100
    turns := os.read_file("./d1p1.data") or {
        eprintln(err)
        return
    }

    println(
        solve_day1_part2(turns, init_pos, limit)
    )
    return //
}

//@ solves day-1 part-2
fn solve_day1_part2(turns string, init_pos int, limit int) int {
    mut dial := init_pos
    mut zero_hit := 0

    mut last := init_pos
    next_turn: for turn in turns.split("\n") {
        if turn == "" {
            continue next_turn
        }

        // Efficient parsing without allocating array for every line
        direction := turn[0]
        // Skip the first character and parse the rest
        number := turn[1..].int()

        for _ in 0..number {
            if direction == `R` {
                dial = (dial + 1) % limit
            } else {
                dial = (dial - 1) % limit
            }

            if dial == 0 {
                zero_hit += 1
            }
        }

        // test: println(dial)
        last = number
    }
    return zero_hit
}

//@ solves day-1 part-1
fn solve_day1_part1(turns string, init_pos int, limit int) int {
    mut dial := init_pos
    mut zero_hit := 0

    next_turn: for turn in turns.split("\n") {
        if turn == "" {
            continue next_turn
        }

        // Efficient parsing without allocating array for every line
        direction := turn[0]
        // Skip the first character and parse the rest
        number := turn[1..].int()

        if direction == `L` {
            dial -= number
        } else {
            dial += number
        }

        dial = dial % limit
        if dial < 0 {
            dial += limit
        }

        if dial == 0 {
            zero_hit += 1
        }
        // test: println(dial)
    }
    return zero_hit
}