module main

import os

fn main() {

    data := os.read_file("./input/day2") or {
        eprintln(err)
        return
    }

    println(solve_day1_part2(data.split("\n")))
    return
}

//@ this solves day2 part2
fn solve_day2_part2(data []string) int {
    mut result := 0

    mut pos   := 0
    mut depth := 0
    mut aim   := 0

    for item in data {
        action := item.split(" ")[0]
        number := item.split(" ")[1].int()

        if action.str() == "forward" {
            pos += number
            depth += aim * number
        } else if action.str() == "down" {
            aim += number
        } else {
            aim -= number
        }

    }
    result = pos * depth
    return result
}

//@ this solves day2 part1
fn solve_day2_part1(data []string) int {
    mut result := 0

    mut pos   := 0
    mut depth := 0

    for item in data {
        action := item.split(" ")[0]
        number := item.split(" ")[1].int()

        if action.str() == "forward" {
            pos += number
        } else if action.str() == "down" {
            depth += number
        } else {
            depth -= number
        }

    }
    result = pos * depth
    return result
}