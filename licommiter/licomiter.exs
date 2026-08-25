#
# Borrowed from: https://github.com/ProbeOpt/elixer/vingle/vingle.exs
#

defmodule Main do
  def main do
    {licommiter, version} = {"licommiter", "0.1.0"}
    IO.puts("#{licommiter} (#{version})")

    argv = System.argv()
    {target} =
      case argv do
        [t] ->
          {t}
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

    # add all changes first, because somewhy it is not doing it!
    {output, exit_code} = System.cmd("sh",["-c","cd #{target} && git add ."])

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

        _ ->
          :err
      end
    end)

    {output, exit_code} = System.cmd("sh", ["-c", "git branch"])
    case exit_code do
      0 -> :ok
      _ -> IO.puts("error!!!")
        System.halt(1)
    end
    branch_name =
      output
      |> String.split(" ")
      |> Enum.at(-1)
    IO.puts(branch_name)

    {output, exit_code} = System.cmd("sh", ["-c", "git push origin #{branch_name}"])
  end

  def usage do
    IO.puts("Usage: licommiter <file> [options]")
  end

  def contents(target) do
    entries = File.ls!(target)

    Enum.reduce(entries, [], fn file_name, acc ->
      # Construct full path
      full_path = Path.join(target, String.trim(file_name))

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
end

Main.main()