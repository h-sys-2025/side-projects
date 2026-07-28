defmodule Generator do
  def next(last_word, model) do
    rand_value = :rand.uniform()

    case Map.get(model, last_word) do
      map_of_next_words when is_map(map_of_next_words) ->
        float_list = Map.values(map_of_next_words)

        nearest_float = find_nearest(rand_value, float_list)

        {word, _float} = Enum.find(map_of_next_words, fn {_word, float} -> float == nearest_float end)
        word

      nil ->
        model |> Map.keys() |> Enum.random()
    end
  end

  def find_nearest(target, float_list) do
    Enum.min_by(float_list, fn float -> abs(float - target) end, fn -> 0.0 end)
  end

  def generate(prompt, limit, model) do
    initial_words = String.split(prompt, " ")

    1..limit
    |> Enum.reduce(initial_words, fn _i, acc ->
      last_word = List.last(acc)

      next_word = Generator.next(last_word, model)

      acc ++ [next_word]
    end)
  end
end

defmodule Main do
  def main() do
    model_file = "./model-v1.bin"

    content =
      case File.read(model_file) do
        {:ok, content} ->
          content
        _error ->
          IO.puts("failed to read model file: #{model_file}")
          System.halt(1)
      end

    model = :erlang.binary_to_term(content)
    # IO.inspect(model, label: "model is")

    prompt = "39"
    limit = 25
    result = Generator.generate(prompt, limit, model)

    IO.puts("\nGenerated text:")
    IO.puts(Enum.join(result, " "))
  end
end

Main.main()