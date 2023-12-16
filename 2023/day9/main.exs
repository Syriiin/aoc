defmodule Day9 do
  defp to_lines(input) do
    String.split(input, "\n", trim: true)
  end

  defp parse_sequence(sequence_line) do
    sequence_line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_sequences(raw_sequences) do
    raw_sequences
    |> to_lines()
    |> Enum.map(&parse_sequence/1)
  end

  defp find_next_value(sequence) do
    if Enum.all?(sequence, fn x -> x == 0 end) do
      0
    else
      derivative_sequence =
        sequence
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [x1, x2] -> x2 - x1 end)

      List.last(sequence) + find_next_value(derivative_sequence)
    end
  end

  defp find_next_values(sequences) do
    Enum.map(sequences, &find_next_value/1)
  end

  defp process_input(input_string) do
    next_value_sum =
      input_string
      |> parse_sequences()
      |> find_next_values()
      |> Enum.sum()

    %{
      part1: next_value_sum,
      part2: nil
    }
  end

  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        result = process_input(input)

        IO.puts("Part 1 Answer: " <> inspect(result.part1, pretty: true))
        IO.puts("Part 2 Answer: " <> inspect(result.part2, pretty: true))

      {:error, _} ->
        IO.puts("unable to read " <> path <> "\nexiting...")
        System.halt(1)
    end
  end
end

Day9.main("input.txt")
