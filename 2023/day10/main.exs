defmodule Tile do
  @enforce_keys [:coords, :type]
  defstruct [:coords, :type]

  def parse(tile_string, row, column) do
    type =
      case tile_string do
        "|" -> :vertical_pipe
        "-" -> :horizontal_pipe
        "L" -> :north_east_bend
        "J" -> :north_west_bend
        "7" -> :south_west_bend
        "F" -> :south_east_bend
        "." -> :ground
        "S" -> :start
      end

    %Tile{coords: {row, column}, type: type}
  end

  def get_printable_tile(tile) do
    case tile.type do
      :vertical_pipe -> "║"
      :horizontal_pipe -> "═"
      :north_east_bend -> "╚"
      :north_west_bend -> "╝"
      :south_west_bend -> "╗"
      :south_east_bend -> "╔"
      :ground -> " "
      :start -> "▉"
    end
  end

  # Return coords of connecting tiles in clockwise order
  def get_connecting_coords(tile) do
    {row, column} = tile.coords

    case tile.type do
      :vertical_pipe -> [{row - 1, column}, {row + 1, column}]
      :horizontal_pipe -> [{row, column + 1}, {row, column - 1}]
      :north_east_bend -> [{row - 1, column}, {row, column + 1}]
      :north_west_bend -> [{row, column - 1}, {row - 1, column}]
      :south_west_bend -> [{row + 1, column}, {row, column - 1}]
      :south_east_bend -> [{row, column + 1}, {row + 1, column}]
      :start -> [{row - 1, column}, {row, column + 1}, {row + 1, column}, {row, column - 1}]
      :ground -> []
    end
  end

  def connects_to?(tile, coords) do
    tile
    |> get_connecting_coords()
    |> Enum.any?(fn c -> c == coords end)
  end
end

defmodule Maze do
  require Integer
  @enforce_keys [:tiles, :starting_coords, :main_pipe_coords, :enclosed_coords]
  defstruct [:tiles, :starting_coords, :main_pipe_coords, :enclosed_coords]

  defp parse_line(maze_line, row) do
    maze_line
    |> String.split("", trim: true)
    |> Stream.with_index()
    |> Enum.map(fn {char, index} -> Tile.parse(char, row, index) end)
  end

  def parse(maze_string) do
    tile_list =
      maze_string
      |> String.split("\n", trim: true)
      |> Stream.with_index()
      |> Enum.map(fn {line, index} -> parse_line(line, index) end)

    tiles =
      tile_list
      |> List.flatten()
      |> Enum.map(fn tile -> {tile.coords, tile} end)
      |> Map.new()

    starting_coords =
      Enum.find_value(tiles, fn {coords, tile} -> if tile.type == :start, do: coords end)

    main_pipe_coords =
      get_main_pipe(tiles, starting_coords)

    # replace starting tile with appropriate pipe to enclose the loop
    starting_pipe = %Tile{
      coords: starting_coords,
      type: infer_pipe_type(starting_coords, tiles, main_pipe_coords)
    }

    tiles = Map.put(tiles, starting_coords, starting_pipe)

    enclosed_coords =
      get_enclosed_tiles(tiles, main_pipe_coords)

    %Maze{
      tiles: tiles,
      starting_coords: starting_coords,
      main_pipe_coords: main_pipe_coords,
      enclosed_coords: enclosed_coords
    }
  end

  defp get_pipe_type_for_directions(direction1, direction2) do
    direction_set = MapSet.new([direction1, direction2])

    cond do
      MapSet.equal?(direction_set, MapSet.new([:north, :south])) -> :vertical_pipe
      MapSet.equal?(direction_set, MapSet.new([:west, :east])) -> :horizontal_pipe
      MapSet.equal?(direction_set, MapSet.new([:north, :east])) -> :north_east_bend
      MapSet.equal?(direction_set, MapSet.new([:north, :west])) -> :north_west_bend
      MapSet.equal?(direction_set, MapSet.new([:south, :west])) -> :south_west_bend
      MapSet.equal?(direction_set, MapSet.new([:south, :east])) -> :south_east_bend
    end
  end

  defp get_direction_for_coords(coords1, coords2) do
    {row1, col1} = coords1
    {row2, col2} = coords2

    cond do
      row2 < row1 -> :north
      row1 < row2 -> :south
      col1 < col2 -> :east
      col2 < col1 -> :west
      true -> :error
    end
  end

  defp infer_pipe_type(coords, tiles, pipe_coords) do
    [pipe1, pipe2] =
      pipe_coords
      |> Enum.map(fn coords -> tiles[coords] end)
      |> Enum.filter(fn tile -> Tile.connects_to?(tile, coords) end)
      |> Enum.sort_by(fn tile -> tile.coords end)

    get_pipe_type_for_directions(
      get_direction_for_coords(coords, pipe1.coords),
      get_direction_for_coords(coords, pipe2.coords)
    )
  end

  defp get_printable_tile(maze, tile) do
    tile_char = Tile.get_printable_tile(tile)

    cond do
      maze.starting_coords == tile.coords ->
        IO.ANSI.red() <> tile_char <> IO.ANSI.reset()

      Enum.member?(maze.main_pipe_coords, tile.coords) ->
        IO.ANSI.green() <> tile_char <> IO.ANSI.reset()

      Enum.member?(maze.enclosed_coords, tile.coords) ->
        IO.ANSI.blue_background() <> tile_char <> IO.ANSI.reset()

      true ->
        tile_char
    end
  end

  defp get_printable_row(maze, row_tiles) do
    row_tiles
    |> Enum.map(fn {_, tile} -> get_printable_tile(maze, tile) end)
    |> Enum.join()
  end

  def get_printable_maze(maze) do
    maze.tiles
    |> Enum.group_by(fn {coords, _} -> elem(coords, 0) end)
    |> Enum.sort()
    |> Enum.map(fn {_, row_tiles} -> get_printable_row(maze, Enum.sort(row_tiles)) end)
    |> Enum.join("\n")
  end

  defp follow_pipe_to_start(tiles, start_coords, current_tile, previous_coords) do
    next_tile =
      current_tile
      |> Tile.get_connecting_coords()
      |> Enum.find_value(fn coords ->
        tile = tiles[coords]

        if tile != nil and coords != previous_coords and
             Tile.connects_to?(tile, current_tile.coords) do
          tile
        end
      end)

    cond do
      next_tile == nil ->
        :error

      next_tile.coords == start_coords ->
        [current_tile.coords]

      true ->
        [
          current_tile.coords
          | follow_pipe_to_start(tiles, start_coords, next_tile, current_tile.coords)
        ]
    end
  end

  # Returns list of coordinate tuples starting
  defp get_main_pipe(tiles, starting_coords) do
    follow_pipe_to_start(tiles, starting_coords, tiles[starting_coords], nil)
  end

  defp coords_are_enclosed(coords, pipe_tiles) do
    {row, col} = coords

    # could optimise by going to nearest edge of pipe bounding box, not always left
    inline_pipe_tiles =
      pipe_tiles
      |> Enum.filter(fn tile ->
        {tile_row, tile_col} = tile.coords
        # is to left of coords, in same row
        tile_row == row and tile_col < col
      end)

    {vertical_pipes, rest_pipes} =
      inline_pipe_tiles
      |> Enum.split_with(fn tile -> tile.type == :vertical_pipe end)

    s_bend_pairs =
      rest_pipes
      |> Enum.reject(fn tile -> tile.type == :horizontal_pipe end)
      |> Enum.sort_by(fn bend_tile -> elem(bend_tile.coords, 1) end, :desc)
      |> Enum.chunk_every(2)
      |> Enum.filter(fn [bend1, bend2] ->
        case {bend1.type, bend2.type} do
          # u-bend
          {:north_west_bend, :north_east_bend} -> false
          # n-bend
          {:south_west_bend, :south_east_bend} -> false
          # s-bends
          _ -> true
        end
      end)

    count_pipe_crossing = length(vertical_pipes) + length(s_bend_pairs)

    Integer.is_odd(count_pipe_crossing)
  end

  defp get_enclosed_tiles(tiles, pipe_coords) do
    pipe_tiles =
      pipe_coords
      |> Enum.map(fn coords -> tiles[coords] end)

    # could optimise a bit by also excluding anything outside the pipe bounding box
    tiles
    |> Map.keys()
    |> Enum.reject(fn coords -> Enum.member?(pipe_coords, coords) end)
    |> Enum.filter(fn coords -> coords_are_enclosed(coords, pipe_tiles) end)
  end
end

defmodule Day10 do
  defp process_input(input_string) do
    maze = Maze.parse(input_string)

    maze
    |> Maze.get_printable_maze()
    |> IO.puts()

    main_pipe_max_distance =
      maze.main_pipe_coords
      |> length()
      |> div(2)

    count_enclosed_tiles =
      maze.enclosed_coords
      |> length()

    %{
      part1: main_pipe_max_distance,
      part2: count_enclosed_tiles
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

Day10.main("input.txt")
