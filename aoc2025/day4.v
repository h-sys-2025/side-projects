module main

import os

fn main() {
    data := os.read_file('./day4.input') or {
        eprintln('Error reading file: $err')
        return
    }
    println(solve_day4_part1(data.split('\n')))
}

fn solve_day4_part1(lines []string) int {
    if lines.len == 0 {
        return 0
    }

    // Filter out any empty lines
    mut grid := [][]rune{}
    for line in lines {
        trimmed := line.trim_space()
        if trimmed.len > 0 {
            grid << trimmed.runes()
        }
    }

    if grid.len == 0 {
        return 0
    }

    rows := grid.len
    cols := grid[0].len

    mut count := 0

    for i in 0 .. rows {
        for j in 0 .. cols {
            if grid[i][j] != `@` {
                continue
            }

            // Count neighboring @ (8 possible directions)
            mut neighbors := 0
            for di in -1 .. 2 {
                for dj in -1 .. 2 {
                    if di == 0 && dj == 0 {
                        continue // skip self
                    }
                    ni := i + di
                    nj := j + dj
                    if ni >= 0 && ni < rows && nj >= 0 && nj < cols {
                        if grid[ni][nj] == `@` {
                            neighbors++
                        }
                    }
                }
            }

            if neighbors < 4 {
                count++
            }
        }
    }

    return count
}