defmodule Tokenizer do
  # this will tokenize it!
  # first, it will have to .to_lower() all of it!
  # then,  split by special-chars and spaces
  # then,  return all items.
  def tokenize(data) do
    {data} =
      case data do
        "" ->
          IO.puts("data is empty.")
          System.halt()
        _ ->
          {data}
      end

    u1 = String.split(data, "\n", trim: true)
    {no_lines} =
      case Enum.count(u1) > 0 do
        true ->
          {u1}
        false ->
          IO.puts("there are no lines in data file. (tokenizer.exs)")
          System.halt()
      end

    delim_lines =
      no_lines
      |> Enum.join("|")
      |> String.split(" ")
      |> Enum.join("|")

    special_chars = "!@#$%^&*(),.?:;"

    # --- start AI code ---
    pattern = Regex.escape(special_chars) |> then(&"[#{&1}]")
    regex = ~r/(#{pattern})/
    no_special_chars = Regex.replace(regex, delim_lines, "|\\1|")
    # --- end AI code ---

    no_special_chars =
      no_special_chars
      |> String.split("||")
      |> Enum.join("|")

    no_special_chars
  end
end

defmodule Main do
  def main() do
    data_file = "./training_corpus.data"
    output_tokens_file = "./tokens.tokens"
    {data} =
      case File.read(data_file) do
        {:ok, content} ->
          {content}
        {_, _} ->
          IO.puts("failed to read data file: #{data_file}")
          System.halt()
          {""}
      end

    tokens = Tokenizer.tokenize(data)
    IO.puts("tokens: #{tokens}")

    case File.write(output_tokens_file, tokens) do
      :ok ->
        nil
      _ ->
        IO.puts("writing to file #{output_tokens_file} failed!")
        System.halt()
    end
  end
end

Main.main()

# will be continued here: