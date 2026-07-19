module main

import os

fn main() {
    data := os.read_file("./input/day1") or {
        eprintln(err)
        return
    }

    println(solve_day1_part2(data.split("\n")))
    return
}

//@ solves day1 part1
fn solve_day1_part1(data []string) int {
    mut result := 0

    mut last := data[0].int()
    for x in data[1..] {
        if x.int() > last {
            result += 1
            last = x.int()
        } else {
            last = x.int()
        }
    }

    return result
}

//@ solves day1 part2
fn solve_day1_part2(data []string) int {
    mut result := 0

    mut last := 0
    for x in 0..data.len-2 {
        this := data[x].int()+data[x+1].int()+data[x+2].int()
        if this > last && last > 0{
            result += 1
            last = this
        } else {
            last = this
        }
    }


    return result
}