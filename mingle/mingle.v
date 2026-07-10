module main

import os
import time

// Returns true on success, false on failure.
fn add_all_and_commit(message string, repo string) bool {
    // Step 1: git add .
    add_args := ["git", "-C", repo, "add", "."]
    add_result := os.exec(add_args)

    if add_result.exit_code != 0 {
        return false
    }

    // Step 2: git commit -m "message"
    commit_args := ["git", "-C", repo, "commit", "-m", message]
    commit_result := os.exec(commit_args)

    return commit_result.exit_code == 0
}

/*
 * MINGLE -- is a version control automater for my side-projects repo!
 */
fn main() {
    // cd to ../
    bin_path := os.executable()
    dir_path := os.join_path(os.dir(bin_path), "..")

    autodoc_bin_path := os.join_path(dir_path, ".","autodoc","autodoc")

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
    for_dir: for dir in dirs {
        if dir in dirs_not_to_commit {
            println("ignored: ${dir}")
            continue for_dir
        }

        direc1 := dir.split("/")
        direc  := direc1[direc1.len-1]
        side_proj := os.join_path(dir_path, ".", direc)
        msg := "mingle: autocommit ${time.now()}"
        // now file all .v files in them and make docs, using autodoc.
        v_files := os.ls(side_proj) or {
            eprintln("could not read .v files in dir ${side_proj}, skipping autodoc.")
            return
        }
        next_v_file: for file in v_files {
            if os.is_file(os.join_path(side_proj, ".",file)) {
                ig1 := file.split("/")
                name := ig1[ig1.len - 1]
                if name.ends_with(".v") {
                    file_path_x := os.join_path(side_proj,file)
                    println(" -*- autodoc: ${file_path_x}")
                    //command := [autodoc_bin_path,file_path_x]
                    //cmd := os.exec(command)
                    println(" -+- generated docs!")
                }
            } else {
                continue next_v_file
            }
        }
        //
        println(" _*_ commiting: ${side_proj}: message: ${msg} _*_")
        add_all_and_commit(msg, dir_path)
    }
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