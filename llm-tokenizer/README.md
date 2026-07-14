# llm-tokeizer!
```v
_*_ Running: `v run /home/dzebra/Work/probe/Programming/hsys25/side-projects/llm-tokenizer/llm_tok.v` _*_


llm_tok.v:6:8: warning: module 'json' is imported but never used. Use `import json as _`, to silence this warning, or just remove the unused import line
    4 | import os
    5 | import rand
    6 | import json
      |        ~~~~
    7 | import math
    8 |
llm_tok.v:107:4: notice: unused function: `format_and_save`
  105 |
  106 | //@ helper function: format and save to a file!
  107 | fn format_and_save(data string, formatted_file string) {
      |    ~~~~~~~~~~~~~~~
  108 |     os.write_file(formatted_file, format(data).join(" ")) or {
  109 |         eprintln("vould not write to file ${formatted_file}: ${err}")
llm_tok.v:121:4: notice: unused function: `build_model`
  119 | //@ a little vibecoding never hurtes anyone: Generates Order-N Model using single string keys (e.g., "a|b|c")
  120 | //@
  121 | fn build_model(tokens []string, order int) map[string]map[string]f64 {
      |    ~~~~~~~~~~~
  122 |     mut model := map[string]map[string]f64{}
  123 |
llm_tok.v:178:4: notice: unused function: `predict_n`
  176 | //@ for markov chain
  177 | //@ predict_n: Main prediction function with backoff and multi-token support
  178 | fn predict_n(model map[string]map[string]f64, prompt string, n int, temperature f64) []string {
      |    ~~~~~~~~~
  179 |     if n <= 0 { return []string{} }
  180 |
llm_tok.v:27:5: warning: unused variable: `formatted_file`
   25 |         "./../.ignore_this/small_data.txt"
   26 |     }
   27 |     formatted_file := arguments()[2] or {
      |     ~~~~~~~~~~~~~~
   28 |         "./../.ignore_this/formatted_data.txt"
   29 |     }
|it| |wa|s| |a| |br|i|gh|t| |c|o|ld| |da|y| |i|n| |a|p|ri|l| |,| |a|nd| |t|he| |c| |lo|c|ks| |we|r|e| |st|ri| |ki|ng| |t| |hi|r|te|e|n| |.| |w|i|ns| |to| |n| |sm| |it|h| |,| |hi|s| |c| |hi| |n| |n|uz|z|le|d
| |i|n|to| |hi|s| |br| |ea|st| |i|n| |a| |n| |effort| |t|o|escape| |t|h|e| |vil|e| |wind| |,| |slipped|quickly| |t|hrou|gh| |t|h|e| |glass|doors|of|vic|to|ry|m|an|sio|ns| |,| |t|hou|gh| |not|quickly|enou|gh
| |t|o|prevent| |a| |swirl|of|gr|it|ty|dust|from|en|te| |ri|ng| |a| |lo|n|g| |w|it|h| |hi|m|.| |t|h|e| |hall|wa|y| |sm|elt|of| |b|oi|le|d| |c|abbage| |a|nd|o|ld| |ra|g| |mats|.| |a|t| |on| |e| |end|of| |it|
 |a| |c|o|lo|ured|pos|te|r| |,| |t|oo|larg|e| |for| |i|ndoor|d|is|play| |,| |had| |b|een| |t|acked| |t|o| |t|h|e| |wa|ll|.| |it| |depic|te|d|simply| |a| |n| |enormous|face| |,| |more| |t|h|an| |a| |me|tr| |
e| |wid|e| |:| |t|h|e| |fac|e| |of| |a| |m|an| |of| |a|bout|forty|-|five| |,| |w| |it|h| |a| |h|ea|vy| |b|lack|mousta|ch|e| |a|nd|ruggedly|h|an|dsom|e| |f|ea|tures|.| |w|i|ns| |to| |n| |mad|e| |for| |t|h|e|
 |stairs|.| |it| |wa|s|no|use| |t|rying| |t|h|e| |lift|.|even| |a|t| |t|h|e| |best|of| |t|imes| |it| |wa|s|se|ld|om| |w|or|ki|ng| |,| |a|nd| |a|t|present| |t|h|e| |e|le|ct|ri|c| |c|urrent| |wa|s| |c|ut|off|
du|ri|n|g| |da|yli|gh|t|hours|.| |it| |wa|s|part|of| |t|h|e| |ec|on|omy|d|ri|ve| |i| |n| |preparatio|n| |for|hat|e| |we|ek|.| |t|h|e| |flat| |wa|s|seve|n| |fli|gh|ts|up| |,| |a|nd| |w|i|ns|t|on| |,| |w|ho|
|wa|s| |t| |hi|rty|-|nine| |a|nd|had| |a| |va|ri|cos|e| |ulcer| |a|bov|e| |hi|s| |ri| |gh|t| |a|nk|le| |,| |we|nt|s|lo|wly| |,| |restin|g| |several| |t|imes| |on| |t|h|e| |wa|y|.|o|n| |ea| |ch| |l|an|ding|
|,| |oppos|it|e| |t|h|e| |lift|-|shaft| |,| |t|h|e| |pos|te|r| |w| |it|h| |t|h|e| |enormous|fac|e| |gazed|from| |t|h|e| |wa|ll|.| |it| |wa|s| |on| |e| |of| |t|hos|e| |pictures| |w| |hi| |ch| |a|r|e| |so| |c
| |on|t|ri|ved| |t|hat| |t|h|e| |eyes|fol|lo|w|you| |a|bout| |w|he|n| |you|mov|e| |.| |b|i|g| |br|o|th|er| |i|s| |wa|tc|hi|n|g| |you| |,| |t|he| |c|aptio|n| |ben|ea| |th| |it| |r|an| |.|

Process completed with exit code: 0
```