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

    traversed_tile_count =
      map
      |> process_map_traversal(guard_position)
      |> count_traversed_tiles()

    %{
      part1: traversed_tile_count,
      part2: nil
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

  defp mark_tile(map, row_index, col_index) do
    row = Enum.at(map, row_index)
    List.replace_at(map, row_index, List.replace_at(row, col_index, "X"))
  end

  defp process_map_traversal(map, guard_position) do
    new_guard_position = get_next_guard_position(map, guard_position)

    if is_guard_out_of_bounds?(map, new_guard_position) do
      map
    else
      {row_index, col_index, _direction} = new_guard_position
      new_map = mark_tile(map, row_index, col_index)
      process_map_traversal(new_map, new_guard_position)
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
    get_tile_at_location(map, row_index, col_index) == "#"
  end

  defp get_tile_at_location(map, row_index, col_index) do
    row = Enum.at(map, row_index)

    if row == nil do
      nil
    else
      Enum.at(row, col_index)
    end
  end

  defp count_traversed_tiles(map) do
    map
    |> Enum.map(fn row -> Enum.count(row, fn tile -> tile == "X" end) end)
    |> Enum.sum()
  end
end

Day6.main("input.txt")
