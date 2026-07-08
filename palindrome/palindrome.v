module main

fn is_palindrome(text string) string {
   mut is_or_is_not := ""
   // filter out the useless things.
   mut ttext := text.replace("?","").replace(".","").replace("'","").replace(",","").replace("!","").replace(" ","").to_lower() // also lower it!
   limit := (ttext.len / 2)

   // test: println("lenght is ${ttext.len}, limit is ${limit}")
   things := ttext.split("")
   for x in 0..limit {
       back := things[x]
       front := things[things.len-x-1]
       if back != front {
           is_or_is_not = " NOT"
           break
       }
   }
   return is_or_is_not
}

fn main() {
    // easy as it can get!

    mut text_things := []string{} // basic
    text_things << "Was it a car or a cat I saw?"
    text_things << "Madam, I'm Adam."
    text_things << "Go hang a salami, I'm a lasagna hog!"
    text_things << "something, nothing"

    for text in text_things {
        is_or_is_not := is_palindrome(text)
        println("'${text}' is${is_or_is_not} a palindrome")
    }

    return
}