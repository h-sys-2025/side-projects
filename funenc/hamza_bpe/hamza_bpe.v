module hamza_bpe

// only used for file loading and saving: import os
fn split_2(text string) []string {
    mut z := ""
    mut w := []string{}
    for x in text.split("") {
        for y in x {
            if z.len < 2 {
                z = "${z}${rune(y)}"
            } else {
                w << z
                z = ""
            }
        }
    }

    return w
}

pub fn please_encode_this(message string) (string, map[string]string) {
    // byte pair encoding, oh yeah!
    // res: https://en.wikipedia.org/wiki/Byte-pair_encoding
    mut text := message
    text = text.to_lower()

    // chinese failed: unused_placeholder_bytes := "人大大小小中上下天地心水火木山女子爱家学生月日明和国年时生友好新老高美文语信电电话车路书字口耳手足目食鱼鸟虫"
    unused_placeholder_bytes := "ABCDEFGHIJKLMNOPQRSTUVWXYZ" // just use uppercase english

    mut unused_placeholder_i := 0

    mut byte_ranking := map[string]int

    mut translation_table := map[string]string

    // first, we need to divide text into: [][2]char - list of 2 characters.
    bytes := split_2(text)

    // now rank all byte pairs
    for x in bytes {
        byte_ranking[x] += 1
    }

    // test: verbose: println(byte_ranking)

    // then we need unused place-holder bytes, how? lets use chinese or arabic ones? no, Lets use roman? I need atleast 50, let me check:
    // we got unused_placeholder_bytes from web, easy!

    for byte_pair, _ in byte_ranking {
        if unused_placeholder_i < unused_placeholder_bytes.len {
            bplaceholder := unused_placeholder_bytes[unused_placeholder_i]
            unused_placeholder_i += 1
            // test: verbose: println("replacing: ${byte_pair} -> ${rune(bplaceholder)}")
            text = text.replace(byte_pair, rune(bplaceholder).str())
            translation_table[byte_pair] = rune(bplaceholder).str()
        } else {
            break
        }
    }
    // println(translation_table)
    // println(text)

    /* WE DO NOT NEED TO SAVE THEM RN!
    output_path := os.dir(os.executable())

    translation_table_path := os.join_path(output_path,".","translation.table")
    encoded_file_path := os.join_path(output_path,".","encoded.text")

    os.write_file(translation_table_path, "${translation_table}") or {
        println("[!] writing to ${translation_table_path}: failed!")
        return
    }
    println("[+] writing to ${translation_table_path}: ok!")

    os.write_file(encoded_file_path, text) or {
        println("[!] Writing to ${encoded_file_path}: failed!")
        return
    }
    println("[+] Writing to ${encoded_file_path}: ok!")
    */

    // now we write the reverser
    // load both files? no-need!

    // done
    return text, translation_table
}