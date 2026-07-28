defmodule Trainer do
  def train_on_tokens(tokens) do
    # 1. get tokens from a file!
    # 2. train a model on it!
    # 3. return model!
    tokens =
      tokens
      |> String.split("|")
      |> Enum.chunk_every(2, 1, :discard)

    model = %{}

    model = Enum.reduce(tokens, %{}, fn [word1, word2], acc ->
      update_in(
        acc,
        [Access.key(word1, %{}), Access.key(word2, 0.0)],
        fn current_value -> current_value + 0.1 end
      )
    end)

    # convert floats to percentages.
    model = Map.new(model, fn {word1, inner_map} ->

      x = inner_map
          |> Map.values()
          |> Enum.sum()

      new_inner_map = if x == 0.0 do
        inner_map
      else
        Map.new(inner_map, fn {word2, value} ->
          new_value = (value / x) * 100
          {word2, new_value}
        end)
      end

      {word1, new_inner_map}
    end)
    {:ok, model}
  end
end

defmodule Main do
  def main() do
    tokens_file_path = "./tokens.tokens"
    model_file_path  = "./model-v1.bin"

    {tokens} =
      case File.read(tokens_file_path) do
        {:ok, content} ->
          {content}
        {_, _} ->
          IO.puts("failed to tokens file: #{tokens_file_path}")
          System.halt()
      end


    {model} =
      case Trainer.train_on_tokens(tokens) do
        {:ok, model} ->
          {model}
        {_, err} ->
          IO.puts("error in generating model: #{err}")
          System.halt()
      end

    IO.inspect(model, label: "model is")

    model =
      model
      |> :erlang.term_to_binary()
      # |> String.split("  ")
      # |> Enum.join(" ")

    case File.write(model_file_path, model) do
      :ok ->
        nil
      _ ->
        IO.puts("writing to file #{model_file_path} failed!")
        System.halt()
    end
  end
end

Main.main()