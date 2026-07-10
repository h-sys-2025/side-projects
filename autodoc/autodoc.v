module main

import os
import arrays

//@ this is DocObj struct, which represents a singular documentation object
//@ like a struct or a fn or module or import
struct DocObj {
pub mut:
	kind     string
	dev_docs []string
	code_ref string
}

//@ this is main Documentation object
struct Documentation {
pub mut:
	stmts  []DocObj
	module string
}

//@ the main function
fn main() {
	// get v file path from arguments!
	source_file_path := arguments()[1] or {
		eprintln('${arguments()[0]}: usage: ${arguments()[0]} <file_path.v>')
		return
	}

	// make sure that file is accessable, and is not root provlidged?
	// and make sure that file is NOT empty
	mut content := os.read_lines(source_file_path) or {
		eprintln('file ${source_file_path} is not a valid file path, or it is not accessable.')
		return
	}
	if content.len < 1 {
		eprintln('file ${source_file_path} has 0 lines of data?')
		return
	}

	mut docs := gen_dev_docs(content)
	md_docs := doc_to_md(docs)
	println(md_docs)
	// save data into .json file
	// load .json file and convert to markdown!
	// exit gracefully!
	return
}

fn doc_to_md(docs Documentation) string {
	mut my_functions := ''
	mut my_structs := ''
	mut my_dependencies := ''
	mut module_name := ''

	for stmt in docs.stmts {
		// doc_md = '${doc_md}\n${stmt.dev_docs.join('\n').replace('//@', '##')}\n```v\n${stmt.code_ref}\n```\n'
		name := stmt.kind
		if name == 'module' {
			if module_name == '' {
				module_name = stmt.code_ref.split(' ')[1]
			}
		} else if name == 'fn' {
			mut dev_docs := ''
			if stmt.dev_docs.len > 0 {
				dev_docs = '\n${stmt.dev_docs.join('\n').replace('//@', '//')}'
			}
			my_functions = '${my_functions}```v${dev_docs}\n${stmt.code_ref}\n```\n'
		} else if name == 'struct' {
			mut dev_docs := ''
			if stmt.dev_docs.len > 0 {
				dev_docs = '\n${stmt.dev_docs.join('\n').replace('//@', '//')}'
			}
			my_structs = '${my_structs}```v${dev_docs}\n${stmt.code_ref}\n```\n'
		} else if name == 'import' {
			mut dev_docs := ''
			if stmt.dev_docs.len > 0 {
				dev_docs = '\n${stmt.dev_docs.join('\n').replace('//@', '//')}'
			}
			my_dependencies = '${my_dependencies}${dev_docs}\n${stmt.code_ref}'
		}
	}

	mut doc_md := ''
	doc_md = '${doc_md}\n# Module:'
	doc_md = '${doc_md}\n- ${module_name}\n'

	doc_md = '${doc_md}\n## Dependencies:'
 doc_md = "${doc_md}\n```v"
	doc_md = '${doc_md}${my_dependencies}'
 doc_md = "${doc_md}\n```\n"

	doc_md = '${doc_md}\n## Functions:'
	doc_md = '${doc_md}\n${my_functions}'

	doc_md = '${doc_md}\n## Structs:'
	doc_md = '${doc_md}\n${my_structs}'

	return doc_md
}

fn gen_dev_docs(content []string) Documentation {
	mut docs := Documentation{}

	// loop:
	// we divide files into batches of 100 lines! so not to overwhelm our RAM!
	chunks := arrays.chunk(content, 100)
	mut dev_docs := []string{}
	for chunk in chunks { // read first 100 lines of file.
		next_line: for lline in chunk {
			line := lline.trim_space()
			if line.starts_with('//@') {
				dev_docs << line
				continue next_line
			}
			if line.starts_with('fn ') {
				docs.stmts << DocObj{
					kind:     'fn'
					dev_docs: dev_docs
					code_ref: line
				}
				dev_docs = []string{}
				continue next_line
			}
			if line.starts_with('struct ') {
				docs.stmts << DocObj{
					kind:     'struct'
					dev_docs: dev_docs
					code_ref: line
				}
				dev_docs = []string{}
				continue next_line
			}
			if line.starts_with('module ') {
				docs.stmts << DocObj{
					kind:     'module'
					dev_docs: dev_docs
					code_ref: line
				}
				dev_docs = []string{}
				continue next_line
			}
			if line.starts_with('import ') {
				docs.stmts << DocObj{
					kind:     'import'
					dev_docs: dev_docs
					code_ref: line
				}
				dev_docs = []string{}
				continue next_line
			}
		}
	}
	return docs
}