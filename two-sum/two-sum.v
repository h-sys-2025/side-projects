module main

fn main() {
    mut list_of_numbers := []int{}
    for x in 0..100 {
        list_of_numbers << x
    }
    target := 69

    // answer := can_two_sum(list_of_numbers, target)
    // println("can two-sum be applied on out list? ${answer}!")
    // if answer == true {
    println("two-sum result of our list is: ${two_sum(list_of_numbers,target)}")
    // }
}

fn can_two_sum(list_of_numbers []int, target int) bool {
    for x in list_of_numbers {
        if target-x in list_of_numbers {
            return true
        }
    }
    return false
}

fn two_sum(list_of_numbers []int, target int) []int {
    mut things := map[int]int{}

    for i, x in list_of_numbers {
        complement := target - x
        if complement in things {
            return [things[complement], i]
        }
        things[x] = i
    }

    return [] // Or handle no-solution case
}

fn two_sum_boring(list_of_numbers []int, target int) string {
    mut result := ""

    for x in list_of_numbers {
        if target-x in list_of_numbers {
             result = "${x} ${target-x}"
            break
        }
    }

    return result
}