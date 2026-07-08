// Brain-F-Encryption
// It is something I invented!

module main

pub struct Bfe {
    pub:
        k_vec []string @[required]
        s_pos int @[required]
    pub mut:
        k_vec_kv map[string]int
        data string
        is_encoded bool
}

fn (mut bfe Bfe) make() {
    for x in 0..bfe.k_vec.len {
        bfe.k_vec_kv[bfe.k_vec[x]] = x
    }
}

fn (mut bfe Bfe) get_next_pos(position int, letter string) int {
    curr_letter := bfe.k_vec[position]
    if curr_letter != letter {
        lettr_loc := bfe.k_vec_kv[letter]
        return lettr_loc - position
    } else {
        return 0
    }
}

fn (mut bfe Bfe) encode_and_ret(text string) string {
    if bfe.k_vec.len < 1 {
        return ""
    }
    if bfe.s_pos < 0 {
        eprintln("-ve s_pos is not allowed!")
        return "" // negative numbers, are not allowed!
    }

    mut encoded := ""
    mut position := bfe.s_pos

    for letter in text.split("") {
        if letter in bfe.k_vec {
            next_pos := bfe.get_next_pos(position, letter)
            if next_pos == 0 {
                encoded = "${encoded}0 "
            } else {
                position += next_pos
                encoded = "${encoded}${next_pos} "
            }
        } else {
            eprintln("k_vec does not have key: ${letter}")
            break
        }
    }

    bfe.data = encoded
    bfe.is_encoded = true
    return encoded
}

fn (mut bfe Bfe) decrypt_and_ret(text string) string {
    if bfe.k_vec.len < 1 {
        return ""
    }
    if bfe.s_pos < 0 {
        eprintln("-ve s_pos is not allowed!")
        return "" // negative numbers, are not allowed!
    }

    mut decoded := ""
    mut position := bfe.s_pos

    for numb in text.split(" ") {
        if numb.int() == 0 {
            decoded = "${decoded}${bfe.k_vec[position]}"
        } else {
            position += numb.int()
            khar := bfe.k_vec[position]
            decoded = "${decoded}${khar}"
        }
    }

    bfe.data = decoded
    bfe.is_encoded = false
    return decoded
}


fn main() {
    // It is an encoding system (kind of an encryption too!)
    text := "This is a secret message!!!!!"

    mut kk_vec := []string{}
    for l in text.split("") {
        if l.str() in kk_vec {} else {
            kk_vec << l.str()
        }
    }

    // in BFE::encryptoin we have 3 inputs and 1 output!: message, k_vec, s_pos
    // in BFE::decryption we have 3 inputs and 1 output!: encoded_msg, k_vec, s_pos
    mut bfe := Bfe{
        k_vec: kk_vec
        s_pos: finite_fields_get_i(kk_vec, 314159) // to generate a s_pos with a BIG number. Why? literally for NO reason!
    }
    bfe.make() // vital!
    encoded_text := bfe.encode_and_ret(text)
    println("Encrypted ${text} -> ${encoded_text}")

    decrypted_text := bfe.decrypt_and_ret(encoded_text)
    println("Decrypted ${encoded_text} -> ${decrypted_text}")
    return
}

fn finite_fields_get_i(list []string, i int) int {
    return i % list.len
}