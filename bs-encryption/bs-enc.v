module main

import encoding.base64

struct Layer {
    pub mut:
        algo string
        name string
}

pub struct BsEnc {
    pub mut:
        layers []Layer
        supports_decrypt bool
    pub:
        name string @[required]
        desc string @[required]
}

fn (mut bs BsEnc) add_layer(name string, hashing_algo string) bool {
    if hashing_algo.to_lower() in all_supported_hashing_algos() {
        bs.layers << Layer{
            algo: hashing_algo
            name: name
        }
        return true
    }
    return false
}

fn (mut bs BsEnc) visualize() {
    mut i := 0;
    for layer in bs.layers {
        println("${i}: ${layer.name} -> ${layer.algo}")
        i += 1
    }
}

fn (bs BsEnc) encrypt(data string, verbose bool) string {
    mut encrypted := ""
    for x in bs.layers {
        if encrypted == "" {
            encrypted = encode(data, x.algo)
        } else {
            encrypted = encode(encrypted, x.algo)
        }
        if verbose == true {
            println("\t_*_ on layer ${x.name}, encrypting with ${x.algo}, value is ${encrypted} _*_")
        }
    }
    return encrypted
}

fn (bs BsEnc) decrypt(data string, verbose bool) string {
    mut decrypted := ""
    for x in bs.layers.reverse() {
        if decrypted == "" {
            decrypted = decode(data, x.algo)
        } else {
            decrypted = decode(decrypted, x.algo)
        }
        if verbose == true {
            println("\t_*_ on layer ${x.name}, decrypting with ${x.algo}, value is ${decrypted} _*_")
        }
    }
    return decrypted
}

fn main() {
    // how can we make a thing as simple as base64 encryption, but as hard to crack as sha256, and in the same time, reversible?
    // here we go!
    // NOTE: If you are reading this, and you are not me, then try to crack some of these yourself, without reviewing the source code!!!

    // lets define out first BSencryption thing!
    mut try_crack_me := BsEnc {
        name: "try_crack_me_0.1"
        desc: "Forget about desc. Just try to crack me bro!"
    }
    // adding layers!
    try_crack_me.add_layer("mumbo jumbo", "base64")
    try_crack_me.add_layer("jungle mingle", "base64-url")
    try_crack_me.supports_decrypt = true

    try_crack_me.visualize()

    // lets test it!
    text := "Brainfuck is an esoteric programming language created in 1993 by Swiss student Urban Müller [it; cs].[1] Designed to be extremely minimalistic, the language consists of only eight simple commands, a data pointer, and an instruction pointer.[2]"
    encrypted := try_crack_me.encrypt(text,true)

    println("encrypted text to: ${encrypted}")
    println("does this support descrypt?: ${try_crack_me.supports_decrypt}")

    if try_crack_me.supports_decrypt == true {
        ttext := try_crack_me.decrypt(encrypted,true)
        println("decrypted to: ${ttext}")
    }

    // done
    return
}

fn all_supported_hashing_algos() []string {
    return "base64 base64-url".split(" ")
}

fn encode(data string, algo string) string {
    if algo == "base64" {
        return base64.encode(data.bytes())
    } else if algo == "base64-url" {
        return base64.url_encode_str(data)
    } else {
        eprintln("algo `${algo}` is not supported!")
        return ""
    }
}

fn decode(data string, algo string) string {
    if algo == "base64" {
        return base64.decode_str(data)
    } else if algo == "base64-url" {
        return base64.url_decode_str(data)
    } else {
        eprintln("algo `${algo}` is not supported!")
        return ""
    }
}