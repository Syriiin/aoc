defmodule Day8 do
  defp to_lines(input) do
    String.split(input, "\n", trim: true)
  end

  # Returns [:left, :right, ...]
  defp parse_directions(raw_directions_line) do
    raw_directions_line
    |> String.split("", trim: true)
    |> Enum.map(fn d ->
      case d do
        "R" -> :right
        "L" -> :left
        _ -> :error
      end
    end)
  end

  # Returns %{"AAA" => %{right: "BBB", left: "CCC"}, ...}
  defp parse_locations(raw_location_lines) do
    raw_location_lines
    |> Enum.map(fn location_line ->
      <<location::binary-size(3), " = (", left::binary-size(3), ", ", right::binary-size(3), ")">> =
        location_line

      %{location => %{right: right, left: left}}
    end)
    |> Enum.reduce(fn m, acc -> Map.merge(acc, m) end)
  end

  # Returns %{directions: ..., locations: ...}
  defp parse_map(raw_map) do
    [directions_line | location_lines] = to_lines(raw_map)

    %{
      directions: parse_directions(directions_line),
      locations: parse_locations(location_lines)
    }
  end

  defp do_follow_map(nil, _, _, _) do
    [:error]
  end

  # Returns list of tuples of location and direction: [{"AAA", :left}, ...]
  defp do_follow_map(current_location, locations, directions, ghost_mode) do
    current_direction = hd(directions)
    new_location = locations[current_location][current_direction]

    case new_location do
      "ZZZ" when ghost_mode == false ->
        [{current_location, current_direction}]

      <<_::binary-size(2), "Z">> when ghost_mode == true ->
        [{current_location, current_direction}]

      _ ->
        [
          {current_location, current_direction}
          | do_follow_map(
              new_location,
              locations,
              # somehow its faster to repeatedly append list head to tail than use Stream.cycle/1???
              tl(directions) ++ [current_direction],
              ghost_mode
            )
        ]
    end
  end

  defp follow_map(map, starting_point, ghost_mode) do
    do_follow_map(starting_point, map.locations, map.directions, ghost_mode)
  end

  defp calculate_steps_to_escape(map) do
    map
    |> follow_map("AAA", false)
    |> length()
  end

  defp lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  defp find_lowest_common_multiple(numbers) do
    Enum.reduce(numbers, fn x, acc -> lcm(acc, x) end)
  end

  defp calculate_ghost_steps_to_escape(map) do
    starting_locations =
      map.locations
      |> Map.keys()
      |> Enum.filter(fn l -> String.ends_with?(l, "A") end)

    steps_required =
      Enum.map(starting_locations, fn l ->
        follow_map(map, l, true) |> length()
      end)

    find_lowest_common_multiple(steps_required)
  end

  defp process_input(input_string) do
    map = parse_map(input_string)

    %{
      part1: calculate_steps_to_escape(map),
      part2: calculate_ghost_steps_to_escape(map)
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

Day8.main("input.txt")

# to solve this, we're going to need to identify the cadence of repeating patterns in each path and extrapolate until the start/end points match
# in other words, we need to count how many steps it takes for each starting point, and find the LCM of those numbers
