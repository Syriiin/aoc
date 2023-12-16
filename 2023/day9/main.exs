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

  defp get_derivative_sequence(sequence) do
    sequence
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [x1, x2] -> x2 - x1 end)
  end

  defp find_next_value(sequence) do
    if Enum.all?(sequence, fn x -> x == 0 end) do
      0
    else
      derivative_sequence = get_derivative_sequence(sequence)
      List.last(sequence) + find_next_value(derivative_sequence)
    end
  end

  defp find_next_values(sequences) do
    Enum.map(sequences, &find_next_value/1)
  end

  defp find_previous_value(sequence) do
    if Enum.all?(sequence, fn x -> x == 0 end) do
      0
    else
      derivative_sequence = get_derivative_sequence(sequence)
      List.first(sequence) - find_previous_value(derivative_sequence)
    end
  end

  defp find_previous_values(sequences) do
    Enum.map(sequences, &find_previous_value/1)
  end

  defp process_input(input_string) do
    sequences = parse_sequences(input_string)

    next_value_sum =
      sequences
      |> find_next_values()
      |> Enum.sum()

    previous_value_sum =
      sequences
      |> find_previous_values()
      |> Enum.sum()

    %{
      part1: next_value_sum,
      part2: previous_value_sum
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
