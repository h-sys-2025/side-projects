use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct ColLoc {
    starting: i32,
    ending: i32,
}

// just like C's typedef.
type ErrorMap = HashMap<i32, HashMap<ColLoc, String>>;

fn fmt_error(errors: &ErrorMap) {
    // Iterate over line numbers (sorted for consistent output)
    let mut lines: Vec<_> = errors
                            .keys()
                            .collect();
    lines.sort();

    for &line_no in lines {
        if let Some(col_map) = errors.get(&line_no) {
            println!("Line {}:", line_no);
            for (loc, msg) in col_map {
                println!("  cols {}-{}: {}", loc.starting, loc.ending, msg);
            }
        }
    }
}

fn main() {
    // Step 1: Craft the structures and hashmaps
    let mut error_info: ErrorMap = HashMap::new();

    // - small helper to easil insert errors
    let mut line_1_map: HashMap<ColLoc, String> = HashMap::new();
    line_1_map.insert(
        ColLoc { starting: 0, ending: 5 },
        "Unexpected token".to_string()
    );
    line_1_map.insert(
        ColLoc { starting: 10, ending: 15 },
        "Missing semicolon".to_string()
    );
    error_info.insert(1, line_1_map);

    // now to test the insertion of another line using easy to use api
    error_info
        .entry(2)
        .or_insert_with(HashMap::new)
        .insert(
            ColLoc { starting: 3, ending: 8 },
            "Invalid type".to_string()
        );

    fmt_error(&error_info);
}