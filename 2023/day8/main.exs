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

  defp do_follow_map(nil, _, _) do
    [:error]
  end

  # Returns list of tuples of location and direction: [{"AAA", :left}, ...]
  defp do_follow_map(current_location, locations, directions) do
    current_direction = hd(directions)
    new_location = locations[current_location][current_direction]

    case new_location do
      "ZZZ" ->
        [{current_location, current_direction}]

      _ ->
        [
          {current_location, current_direction}
          | do_follow_map(
              new_location,
              locations,
              # somehow its faster to repeatedly append list head to tail than use Stream.cycle/1???
              tl(directions) ++ [current_direction]
            )
        ]
    end
  end

  defp follow_map(map) do
    do_follow_map("AAA", map.locations, map.directions)
  end

  # Returns list of tuples of locations and direction: [{["AAA", "BBB"], :left}, ...]
  defp do_ghost_follow_map(current_locations, locations, directions) do
    current_direction = hd(directions)
    new_locations = Enum.map(current_locations, fn l -> locations[l][current_direction] end)

    if Enum.all?(new_locations, fn l -> String.ends_with?(l, "Z") end) do
      [current_direction]
    else
      [
        current_direction
        | do_ghost_follow_map(
            new_locations,
            locations,
            # somehow its faster to repeatedly append list head to tail than use Stream.cycle/1???
            tl(directions) ++ [current_direction]
          )
      ]
    end
  end

  defp ghost_follow_map(map) do
    starting_locations =
      map.locations
      |> Map.keys()
      |> Enum.filter(fn l -> String.ends_with?(l, "A") end)

    do_ghost_follow_map(starting_locations, map.locations, map.directions)
  end

  defp process_input(input_string) do
    map =
      input_string
      |> parse_map()

    step_count_to_escape =
      follow_map(map)
      |> length()

    ghost_step_count_to_escape =
      ghost_follow_map(map)
      |> length()

    %{
      part1: step_count_to_escape,
      part2: ghost_step_count_to_escape
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
