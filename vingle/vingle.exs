#
# Borrowed from: https://github.com/ProbeOpt/elixer/vingle/vingle.exs
#

defmodule Main do
  @vingle  "vingle"
  @version "v0.1-dev"

  def main do
    # Access module attributes directly in the string interpolation
    IO.puts("#{vingle()} (#{version()})")

    argv = System.argv()
    {target, _} =
      case argv do
        [t] ->
          {t, false}
        [t, "--verbose"] ->
          {t, true}
        _ ->
          usage()
          System.halt(1)
      end

    case {String.trim(target) == "", File.exists?(target), File.dir?(target)} do
      {false,true,true} ->
        nil

      {false,false,_} ->
        IO.puts("#{target} does not exist, exiting...")
        System.halt(1)

      {false,true,false} ->
        IO.puts("#{target} is not a dir, expected a dir, exiting...")
        System.halt(1)

      {_,_,_} ->
        usage()
        System.halt(1)
    end

    found = Enum.find(File.ls!(target), fn x -> x == ".git" end)
    case found do
      ".git" ->
        nil
      _ ->
        IO.puts("warn: no .git repo found in #{target}, exiting...")
        System.halt(1)
    end


    {is_dir, entries} =
      case File.dir?(target) do
        true ->
          {true, contents(target)}
        _ ->
          {false, [target]}
      end

    # {commands} =
    #   case is_dir do
    #     true ->
    #       {["git add #{Enum.join(entries, " ")}"]}
    #     _ ->
    #       {["git add #{Enum.at(entries,  0)}"]}
    #   end
    # commands = Enum.join(commands, " && ")

    IO.puts("preparing .v files for autodoc!")
    autodoc_file_path = "/home/dzebra/Work/probe/Programming/hsys25/side-projects/autodoc/autodoc"

    entries = Enum.reduce(entries, entries, fn entry, acc ->
      u1 = String.split(entry,".")
      case u1 > 0 do
        true ->
          extension = u1
            |> Enum.at(-1)

          v_file = case extension do
            "v" ->
              IO.puts(" -- autodoc: #{entry}")
              # autodoc the .v files.
              command = "#{autodoc_file_path} #{entry}"
              {output, exit_code} = System.cmd("sh",["-c","command"])
              case exit_code do
                0 ->
                  # add them to entries list.
                  md_file_path = "#{Path.rootname(entry)}.md"
                  IO.puts(" -- done: #{md_file_path}\n\t#{output}")
                  acc ++ [md_file_path]
                _ ->
                  IO.puts(" -- possible failure:\n\t#{output}")
                  acc
              end
            _ ->
              acc
          end
        _ ->
          acc
      end
    end)

    IO.puts("preparing changes for commit!")
    Enum.each(entries, fn entry ->
      case File.exists?(entry) do
        true ->
          {output, exit_code} = System.cmd("sh", ["-c", "git add #{entry}"])
          case exit_code do
            0 ->
              # IO.puts(" -- Done!")
              :ok
            _ ->
              # IO.puts(" -- exit_code: #{exit_code}")
              :err
          end
          {output, exit_code} = System.cmd("sh", ["-c", "git commit -m 'vingle: autocommit: #{DateTime.utc_now()}'"])
          case exit_code do
            0 ->
              # IO.puts(" -- Done!")
              :ok
            _ ->
              # IO.puts(" -- exit_code: #{exit_code}")
              :err
          end
          IO.puts("adds & commits: #{entry}")

        _ ->
          :err
      end
    end)

    IO.puts("preparing commits for push!")
    {output, exit_code} = System.cmd("sh", ["-c", "git push origin master"])
    case exit_code do
      0 ->
        IO.puts(" -- Done!")
      _ ->
        IO.puts("err: adding failed: #{exit_code}:\n\t#{output}")
    end
  end

  def usage do
    IO.puts("Usage: #{vingle()} <file> [options]")
  end

  def contents(target) do
    entries = File.ls!(target)

    Enum.reduce(entries, [], fn file_name, acc ->
      # Construct full path
      full_path = String.trim("#{target}/#{String.trim(file_name)}")

      cond do
        String.starts_with?(file_name, ".") or String.ends_with?(file_name, ".backup") ->
          acc

        File.dir?(full_path) ->
          nested_files = contents(full_path)
          acc ++ nested_files

        File.regular?(full_path) ->
          # IO.puts("adds: #{full_path}")
          acc ++ [full_path]

        true ->
          # IO.puts("unreachable: ignoring: #{full_path}")
          acc
      end
    end)
  end

  # Public functions to expose module attributes
  defp vingle, do: @vingle
  defp version, do: @version
end

Main.main()

# HELP:
#
# commands:
# - {output, exit_code} = System.shell("ls -la | grep .exs")
# - {output, exit_code} = System.cmd("ls", ["-la"])
# - {output, exit_code} = System.cmd("sh", ["-c", "ls -la | grep .exs"])
#
# file I/O:
# - case File.read("config.txt") do
#     {:ok, content} -> IO.puts(content)
#     {:error, reason} -> IO.puts("Error: #{reason}")
#   end
# - content = File.read!("config.txt")
#
# - File.exists?("data.txt")
# - if File.regular?("data.txt"), do: IO.puts("It is a file")
#
# - {:ok, files} = File.ls(".")
# - case File.ls("/nonexistent") do
#     {:ok, entries} -> IO.inspect(entries)
#     {:error, :enoent} -> IO.puts("Directory not found")
#   end
# - File.ls!(".")
#   |> Enum.filter(&String.ends_with?(&1, ".exs"))
#   |> IO.inspect()