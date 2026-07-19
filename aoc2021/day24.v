module main

import os

fn main() {

    data := os.read_file("./samples/day24") or {
        eprintln(err)
        return
    }

    println(solve_day24_part1(data.split("\n")))

    return
}

fn solve_day24_part1(data []string) i64 {
    mut result := 0
    mut registers := map[string]i64

    next_op: for x in 0..data.len {
        instruction := data[x].str()
        action := instruction.split(" ")[0].str()
        register_ptr := instruction.split(" ")[1..].join(" ")

        if action == "inp" {
            // read input, write it to a
            a := value(register_ptrs.split(" ")[0], registers)
        } else if action == "add" {
            a := value(register_ptr.split(" ")[0], registers)
            b := value(register_ptr.split(" ")[1], registers)
            registers[a.str()] = a + b
        } else if action == "mul" {
            a := value(register_ptr.split(" ")[0], registers)
            b := value(register_ptr.split(" ")[1], registers)
            registers[a] = a * b
        } else if action == "div" {
            a := value(register_ptr.split(" ")[0], registers)
            b := value(register_ptr.split(" ")[1], registers)
            if b == 0 {
                continue next_op
            }
            registers[a.str()] = a / b
        } else if action == "mod" {
            a := value(register_ptr.split(" ")[0], registers)
            b := value(register_ptr.split(" ")[1], registers)
            if a < 0 {
                continue next_op
            }
            if b <= 0 {
                continue next_op
            }
            registers[a.str()] = a % b
        } else if action == "eql" {
            a := value(register_ptr.split(" ")[0], registers)
            b := value(register_ptr.split(" ")[1], registers)
            registers[a] = 0
            if a == b {
                registers[a.str()] = 1
            }
        }
    }

    return result
}

fn value(data string, registers map[string]i64) i64 {
    if data.str() in "wxyz" {
        return i64(registers[data])
    } else {
        return i64(data)
    }
    return -1
}