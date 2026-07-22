module main

import os
import time

//@ Returns true on success, false on failure.
fn add_all_and_commit(message string, file_changed string) bool {
    bin_path := os.executable()
    dir_path := os.join_path(os.dir(bin_path), "..")

    os.chdir(dir_path) or {
        println("Error changing directory: ${err}")
        return false
    }

    // Step 1: git add .
    println(" _#_ commiting ${file_changed}  _#_")

    add_args := ["git", "add", file_changed]
    add_result := os.exec(add_args)

    if add_result.exit_code != 0 {
        println(" _!_ commit failed _!_ \n\t-->${add_result.output}")
        return false
    }

    // Step 2: git commit -m "message"
    commit_args := ["git", "commit", "-m", message]
    commit_result := os.exec(commit_args)
    println(" _#_ commit successfull _#_")

    return commit_result.exit_code == 0
}

//@
//@ MINGLE -- is a version control automater for my side-projects repo!
//@
fn main() {
    // cd to ../
    bin_path := os.executable()
    dir_path := os.join_path(os.dir(bin_path), "..")

    mut commit_all := false
    uu1 := arguments()[1] or {
        ""
    }
    if uu1 == "yas" {
        commit_all = true
    }


    os.chdir(dir_path) or {
        println("Error changing directory: ${err}")
        return
    }

    // find all directories
    entries := os.ls(".") or {
        eprintln("Failed to read directory: ${err}")
        return
    }


    mut dirs := []string{}
    for entry in entries {
        // Construct full path to check if it"s a directory
        full_path := os.join_path(dir_path, entry)

        // Filter only directories (excluding symlinks to directories if desired)
        if os.is_dir(full_path){
            // check if it is NOT .git dir!
            u1 := full_path.split("/")
            if u1[u1.len-1] != ".git"{
                dirs << full_path
            }
        }
    }

    u1 := ["git","add","."]
    _ := os.exec(u1)

    // check if they contain mingle.ignore
    mut dirs_not_to_commit := []string{}
    for_dirs: for dir in dirs {
        files := os.ls(dir) or {
            eprintln("Failed to read directory: ${err}")
            return
        }

        for_files: for file in files {
            if os.is_file(os.join_path(dir, ".",file)) {
                ig1 := file.split("/")
                name := ig1[ig1.len - 1]
                if name == "mingle.ignore" {
                    dirs_not_to_commit << dir
                    continue for_dirs
                }
            } else {
                continue for_files
            }
        }
    }

    // if not then: `git add $dir && git commit -m "mingle: autocommit"`
    _ := autodoc_and_commit(dir_path, commit_all)

    // now git push origin master
    command := ["git","push","origin","master"]
    cmd := os.exec(command)
    println("executed: ${command} -- exit_code: ${cmd.exit_code}")
    if cmd.exit_code != 0 {
        println(" - err: ${cmd.output}")
    } else {
        println(" - success!")
    }
    // exit gracefully
    return
}

fn find_and_autodoc_v_files(side_proj string) {
    // now file all .v files in them and make docs, using autodoc.
    bin_path := os.executable()
    dir_path := os.join_path(os.dir(bin_path), "..")

    autodoc_bin_path := os.join_path(dir_path, ".","autodoc","autodoc")


    v_files := os.ls(side_proj) or {
        eprintln("could not read .v files in dir ${side_proj}, skipping autodoc.")
        return
    }
    next_v_file: for file in v_files {
        something := os.join_path(side_proj, ".",file)
        if os.is_file(something) {
            ig1 := file.split("/")
            name := ig1[ig1.len - 1]
            if name.ends_with(".v") {
                file_path_x := os.join_path(side_proj,".",file)
                /*if os.is_file(file_path_x.replace(".v",".md")) {
                    println(" -*-  [SKIP] autodoc: ${file_path_x}")
                    continue next_v_file
                }*/
                println(" -*- autodoc: ${file_path_x}")
                command := [autodoc_bin_path,file_path_x]
                cmd := os.exec(command)
                if cmd.exit_code != 0 {
                    println(" !!! failed: ${cmd.output}")
                } else {
                    println(" -+- generated docs!")
                }
            }
        } else if os.is_dir(something) {
            find_and_autodoc_v_files(something)
        } else {
            continue next_v_file
        }
    }
}

//@ this function uses advanced strng manipulation to
//@ get the dirs which we need to commit!
fn autodoc_and_commit(dir_path string, commit_all bool) []string {
    autodoc_bin_path := os.join_path(dir_path, ".","autodoc","autodoc")
    mut deleted_items := []string{}
    mut dirs := []string{}

    if commit_all != true {
        git_status := os.exec(["git","status"])
        // test: println(git_status)
        //--
        u1 := git_status.output.split("\n")
        for u2 in u1 {
            line := u2.trim_space()
            lline := line.split(" ")

            for u3 in 0..lline.len {
                u4 := lline[u3]
                if u4 == "modified:" {
                    u5 := lline[u3+3]
                    dirs << u5
                    file_path_x := os.join_path(dir_path,".",u5)
                    println(" _+_ modified: ${file_path_x} _+_")
                    if file_path_x.ends_with(".v") {
                        println(" _!_ seemds to be a .v file! _!_")
                        println(" _+_ autodoc: ${file_path_x} _+_")
                        command := [autodoc_bin_path,file_path_x]
                        cmd := os.exec(command)
                        if cmd.exit_code != 0 {
                            println(" !!! failed: ${cmd.output}")
                        } else {
                            println(" -+- generated docs!")
                        }
                    }
                    add_all_and_commit("mingle-v2: ${time.now()}", file_path_x)
                } else if u4 == "deleted:" {
                    deleted_items << lline[u3+3]
                }
            }
        }
    } else {
        _ := os.exec(["git","add","."])
        all_files := get_all_files(dir_path)
        next_file: for file in all_files {
            file_path_x := file
            if file_path_x.starts_with(".") {
                continue next_file
            }
            if file_path_x.ends_with(".backup") {
                continue next_file
            }

            println(" _+_ modified: ${file_path_x} _+_")
            if file_path_x.ends_with(".v") {
                println(" _!_ seems to be a .v file! _!_")
                println(" _+_ autodoc: ${file_path_x} _+_")
                command := [autodoc_bin_path,file_path_x]
                cmd := os.exec(command)
                if cmd.exit_code != 0 {
                    println(" !!! failed: ${cmd.output}")
                } else {
                    println(" -+- generated docs!")
                }
            }
            add_all_and_commit("mingle-v2: ${time.now()}",file_path_x)
        }
    }
    if deleted_items.len > 0 {
      println("[info] processing deleted files!")
      command := "git add . && git commit -m 'mingle-v2: deleted: ${deleted_items.join(" AND ")}'".split(" ")
      cmd     := os.exec(command)
      if cmd.exit_code != 0 {
          println(" !!! failed: ${cmd.output}")
      } else {
          println(" -+- deleted and comiited!")
      }
    }
    return dirs
}

//@ gets all files
fn get_all_files(dir_path string) []string {
    mut all_files := []string{}
    items := os.ls(dir_path) or {
        return all_files
    }
    for item in items {
        if os.is_file(item) {
            all_files << os.join_path(dir_path,item)
        } else {
            for x in get_all_files(os.join_path(dir_path,".",item)) {
                all_files << x
            }
        }
    }
    return all_files
}