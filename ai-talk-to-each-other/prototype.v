module main

import net.http
import os
import time

fn main() {
    /*

    idea:

    1. spin up 2 AIs: "dagbs/qwen2.5-coder-1.5b-instruct-abliterated:iq4_xs" *2
    2. handle seperate context-windows without destrying my laptop!
    3. CHAT!

    */

    mut skills := Skills{}

    skills.new_skill(
        "bash",
        "Run a shell command and return stdout.",
        ["command:string", "timeout:seconds"],
        exec_bash,
    )

    mut bio := "You are a concise, tool-driven assistant.\n" +
            "also follow these rules:\n" +
            "1. never use emojis in any form.\n" +
            "2. Do not use ascii secial chars.\n" +
            "3. Dont overthink.\n" +
            "4. Dont overdo any task.\n" +
            "5. Think of user as a 10 year old kid, who is stubbrn and kinda stupid, so try to explain hard things like a 10 years old kid.\n" +
            "6. Use basic engligh language words, do not use complex english words.\n" +
           "Use the tool ONLY WHEN YOU REALLY NEED IT, like when you want to list files or dirs, or you want to run a bash command or whatever -- Always use a tool when one is available rather than guessing."

    agent_personality := get_agent_personality()
    bio = "${bio}\n${agent_personality}"

    sys_prompt := gen_sys_prompt(skills, bio)

    mut req := OllamaRequest{
        model:      "dagbs/qwen2.5-coder-1.5b-instruct-abliterated:iq4_xs"
        sys_prompt: sys_prompt
        stream:     true
    }

    // Optional — validate the model exists before sending:
    // ok, errmsg := req.set_model(req.model)
    // if !ok { eprintln("Model error: ${errmsg}") return }

    mut agentic_shit := 2
    agentic_loop: for {
      if agentic_shit == 2 {
        agentic_shit = 0
        continue agentic_loop
      } else if agentic_shit == 1 {
        resp_a := req.chat("continue.")

        parsed_a := skills.parse(resp_a.response)

        if parsed_a.plain_text() != "" {
          println("\n[assistant text]\n${parsed_a.plain_text()}")
        }

        mut executed_results := ""

        if parsed_a.tool_calls.len > 0 {
          println("\n[tool calls detected]\n${parsed_a.fmt_parsed()}")
          y_n := os.input(" [+++] DO YOU WANT TO EXECUTE THEM?: Y/N")
          if y_n.to_lower() == "y" {
            executed_results = "${executed_results}\n${skills.execute_all(parsed_a)}"
            println("\n[tool results]\n${executed_results}")
            req.messages << Message{
              role: "user",
              content: executed_results
            }
            agentic_shit = 1
          } else {
            println("\n[tool call denied]\n[tool results]\n${executed_results}")
            req.messages << Message{
              role: "user",
              content: "USER DENIED TOOL CALL: ${executed_results} -- THINK ABOUT WHY USER DENIED, OR ASK HIM A QUESTION."
            }
            agentic_shit = 1
          }

        } else {
          println("\n(no tool calls detected)")
        }

        agentic_shit = 0
        continue agentic_loop
      } else {
        user_input := os.input(">>> ")
        if user_input == "exit" {
          goto end_agendtic_loop
        }

        resp_a := req.chat(user_input)
        //println("\n[raw response]\n${resp_a.response}")

        parsed_a := skills.parse(resp_a.response)

        if parsed_a.plain_text() != "" {
          println("\n[assistant text]\n${parsed_a.plain_text()}")
        }

        mut executed_results := ""

        if parsed_a.tool_calls.len > 0 {
          println("\n[tool calls detected]\n${parsed_a.fmt_parsed()}")
          y_n := os.input(" [+++] DO YOU WANT TO EXECUTE THEM?: Y/N")
          if y_n.to_lower() == "y" {
            executed_results = "${executed_results}\n${skills.execute_all(parsed_a)}"
            println("\n[tool results]\n${executed_results}")
            req.messages << Message{
              role: "user",
              content: executed_results
            }
            agentic_shit = 1
          } else {
            println("\n[tool call denied]\n[tool results]\n${executed_results}")
            req.messages << Message{
              role: "user",
              content: "USER DENIED TOOL CALL: ${executed_results} -- THINK ABOUT WHY USER DENIED, OR ASK HIM A QUESTION."
            }
            agentic_shit = 1
          }

        } else {
          println("\n(no tool calls detected)")
        }
        continue agentic_loop
      }
    }

    end_agendtic_loop:
    // println(req.messages)
    mut chat_session := ""
    for x in req.messages {
      chat_session = "${chat_session}\n${x.role}:${x.content}"
    }
    os.execute("echo \'${chat_session}\' > /tmp/chat.session")
    return
}

fn exec_bash(args map[string]string) string {
    t_start := time.now().unix()
    cmd     := args["command"] or { return "Error: missing command" }
    timeout := args["timeout"] or { "10" }

    // Construct the shell command with timeout
    shell_cmd := 'timeout ${timeout} /bin/sh -c "${cmd}"'

    // Execute the shell command and capture the result
    result := os.execute(shell_cmd)

    t_end := time.now().unix()
    time_taken := t_end - t_start
    return "EXIT CODE: ${result.exit_code} \n OUTPUT: ${result.output}\n [info] time-taken: ${time_taken}-seconds (max-timeout=${timeout}-seconds)"
}

fn get_agent_personality() string {
    mut agent := os.read_file("../agents.md/Basic.agent.md") or {
        return "AGENT_FILE_NOW_FOUND, TELL USER THAT AGENT FILE FAILED TO LOAD, YOU CANNOT WORK WITHOUT AGENTFILE. ASK USER TO EXIT."
    }
    return agent
}