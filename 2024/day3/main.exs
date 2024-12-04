defmodule Day3 do
  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        result = process_input(input)

        result.part1
        |> inspect(pretty: true)
        |> (&("Part 1 Answer: " <> &1)).()
        |> IO.puts()

        result.part2
        |> inspect(pretty: true)
        |> (&("Part 2 Answer: " <> &1)).()
        |> IO.puts()

      {:error, _} ->
        {
          IO.puts("unable to read input.txt. exiting..."),
          exit({:shutdown, 1})
        }
    end
  end

  defp process_input(input) do
    total =
      input
      |> get_mul_calls()
      |> perform_multiplications()
      |> Enum.sum()

    %{
      part1: total,
      part2: nil
    }
  end

  defp get_mul_calls(corrupted_memory) do
    Regex.scan(~r/mul\((\d{1,3},\d{1,3})\)/, corrupted_memory)
    |> Enum.map(fn [_, args] -> String.split(args, ",") end)
    |> Enum.map(fn [arg1, arg2] -> {String.to_integer(arg1), String.to_integer(arg2)} end)
  end

  defp perform_multiplications(mul_calls) do
    mul_calls
    |> Enum.map(fn {x, y} -> x * y end)
  end
end

Day3.main("input.txt")
