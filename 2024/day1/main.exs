defmodule Day1 do
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
    {left_list, right_list} =
      input
      |> to_lines()
      |> to_location_lists()

    total_distance =
      {Enum.sort(left_list), Enum.sort(right_list)}
      |> get_distances()
      |> Enum.sum()

    %{
      part1: total_distance,
      part2: nil
    }
  end

  defp to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  defp to_location_lists(lines) do
    lines
    |> Enum.map(&line_to_tuple_of_locations/1)
    |> Enum.unzip()
  end

  defp line_to_tuple_of_locations(line) do
    line
    |> String.split()
    |> Enum.map(&parse_location/1)
    |> List.to_tuple()
  end

  defp parse_location(string_location) do
    {number, _} = Integer.parse(string_location)
    number
  end

  defp get_distances({left_list, right_list}) do
    left_list
    |> Enum.zip(right_list)
    |> Enum.map(fn {loc1, loc2} -> abs(loc1 - loc2) end)
  end
end

Day1.main("input.example.txt")
