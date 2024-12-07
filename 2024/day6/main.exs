defmodule Day6 do
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
    %{map: map, guard_position: guard_position} =
      parse_map(input)

    traversed_positions =
      map
      |> process_map_traversal(guard_position)
      |> Enum.reverse()

    traversed_tile_count =
      traversed_positions
      |> Enum.map(fn position -> position_to_location(position) end)
      |> Enum.sort()
      |> Enum.dedup()
      |> Enum.count()

    looping_obstacles_count =
      find_looping_obstacles(map, guard_position, traversed_positions)
      |> Enum.count()

    %{
      part1: traversed_tile_count,
      part2: looping_obstacles_count
    }
  end

  defp parse_map(input) do
    tiles =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    guard_row_index = Enum.find_index(tiles, fn row -> Enum.any?(row, &is_guard_tile/1) end)
    guard_row = Enum.at(tiles, guard_row_index)
    guard_col_index = Enum.find_index(guard_row, &is_guard_tile/1)
    guard_tile = Enum.at(guard_row, guard_col_index)
    guard_direction = get_guard_direction(guard_tile)
    map = mark_tile(tiles, guard_row_index, guard_col_index)

    %{
      map: map,
      guard_position: {
        guard_row_index,
        guard_col_index,
        guard_direction
      }
    }
  end

  defp is_guard_tile(tile) do
    get_guard_direction(tile) != nil
  end

  defp get_guard_direction(tile) do
    case tile do
      "^" -> :up
      ">" -> :right
      "V" -> :down
      "<" -> :left
      _ -> nil
    end
  end

  defp mark_tile(map, row_index, col_index, marker \\ "X") do
    row = Enum.at(map, row_index)
    List.replace_at(map, row_index, List.replace_at(row, col_index, marker))
  end

  defp process_map_traversal(map, guard_position, past_positions \\ []) do
    new_guard_position = get_next_guard_position(map, guard_position)

    cond do
      is_guard_out_of_bounds?(map, new_guard_position) ->
        [guard_position | past_positions]

      Enum.member?(past_positions, new_guard_position) ->
        nil

      true ->
        {row_index, col_index, _direction} = new_guard_position
        new_map = mark_tile(map, row_index, col_index)
        process_map_traversal(new_map, new_guard_position, [guard_position | past_positions])
    end
  end

  defp is_guard_out_of_bounds?(map, {row_index, col_index, _direction}) do
    get_tile_at_location(map, row_index, col_index) == nil
  end

  defp get_next_guard_position(map, {row_index, col_index, direction}) do
    {next_row_index, next_col_index} = get_next_location(row_index, col_index, direction)

    if obstacle_at_location?(map, next_row_index, next_col_index) do
      {row_index, col_index, get_next_direction(direction)}
    else
      {next_row_index, next_col_index, direction}
    end
  end

  defp get_next_location(row_index, col_index, direction) do
    case direction do
      :up -> {row_index - 1, col_index}
      :right -> {row_index, col_index + 1}
      :down -> {row_index + 1, col_index}
      :left -> {row_index, col_index - 1}
    end
  end

  defp get_next_direction(direction) do
    case direction do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
  end

  defp obstacle_at_location?(map, row_index, col_index) do
    tile = get_tile_at_location(map, row_index, col_index)
    tile == "#" or tile == "O"
  end

  defp get_tile_at_location(map, row_index, col_index) do
    if row_index < 0 or col_index < 0 do
      nil
    else
      row = Enum.at(map, row_index)

      if row == nil do
        nil
      else
        Enum.at(row, col_index)
      end
    end
  end

  defp position_to_location({row_index, col_index, _direction}) do
    {row_index, col_index}
  end

  defp find_looping_obstacles(map, starting_position, traversed_positions) do
    starting_location = position_to_location(starting_position)

    traversed_positions
    |> Enum.chunk_every(2, 1)
    |> Enum.filter(fn x -> Enum.count(x) == 2 end)
    |> Enum.map(fn [start_pos, position] -> [start_pos, position_to_location(position)] end)
    |> Enum.filter(fn [_start_pos, location] -> location != starting_location end)
    |> Enum.dedup_by(fn [_start_pos, location] -> location end)
    |> Enum.filter(fn [start_pos, location] -> position_to_location(start_pos) != location end)
    |> Enum.sort_by(fn [_start_pos, location] -> location end)
    |> Enum.filter(fn [guard_start_position, location] ->
      obstacle_causes_loop?(location, map, guard_start_position) and
        obstacle_causes_loop?(location, map, starting_position)
    end)
    |> Enum.map(fn [_guard_start_position, location] -> location end)
    |> Enum.sort()
    |> Enum.dedup()
  end

  defp obstacle_causes_loop?({row_index, col_index}, map, guard_start_position) do
    map_with_obstacle = mark_tile(map, row_index, col_index, "O")
    process_map_traversal(map_with_obstacle, guard_start_position) == nil
  end
end

Day6.main("input.txt")
