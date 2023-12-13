defmodule Day6 do
  defp to_lines(input) do
    String.split(input, "\n", trim: true)
  end

  # Returns [%{time: 0, distance: 0}, ...]
  defp parse_races(race_timesheet) do
    [time_line, distance_line] = race_timesheet |> to_lines()
    ["Time:" | time_strings] = time_line |> String.split()
    ["Distance:" | distance_strings] = distance_line |> String.split()

    Enum.zip(time_strings, distance_strings)
    |> Enum.map(fn {time, distance} ->
      %{duration: String.to_integer(time), record_distance: String.to_integer(distance)}
    end)
  end

  defp parse_single_race(race_timesheet) do
    [time_line, distance_line] = race_timesheet |> to_lines()
    ["Time:" | time_strings] = time_line |> String.split()
    ["Distance:" | distance_strings] = distance_line |> String.split()

    %{
      duration: Enum.join(time_strings) |> String.to_integer(),
      record_distance: Enum.join(distance_strings) |> String.to_integer()
    }
  end

  defp get_possible_outcomes(duration) do
    0..duration
    |> Enum.map(fn hold_time -> {hold_time, (duration - hold_time) * hold_time} end)
  end

  # Returns number of possible ways to win the race
  defp count_win_options(race) do
    race.duration
    |> get_possible_outcomes()
    |> Enum.filter(fn {_, distance} -> distance > race.record_distance end)
    |> length()
  end

  defp process_input(input_string) do
    part1 =
      input_string
      |> parse_races()
      |> Enum.map(&count_win_options/1)
      |> Enum.product()

    part2 =
      input_string
      |> parse_single_race()
      |> count_win_options()

    %{
      part1: part1,
      part2: part2
    }
  end

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
          IO.puts("unable to read" <> path <> "\nexiting..."),
          exit({:shutdown, 1})
        }
    end
  end
end

Day6.main("input.txt")
