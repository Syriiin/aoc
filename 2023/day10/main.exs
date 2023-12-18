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
  @enforce_keys [:tiles, :starting_coords]
  defstruct [:tiles, :starting_coords]

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

    %Maze{tiles: tiles, starting_coords: starting_coords}
  end

  defp get_printable_row(row_tiles) do
    row_tiles
    |> Enum.map(fn {_, tile} -> Tile.get_printable_tile(tile) end)
    |> Enum.join()
  end

  def get_printable_maze(maze) do
    maze.tiles
    |> Enum.group_by(fn {coords, _} -> elem(coords, 0) end)
    |> Enum.sort()
    |> Enum.map(fn {_, row_tiles} -> get_printable_row(Enum.sort(row_tiles)) end)
    |> Enum.join("\n")
  end

  defp get_tile(maze, coords) do
    maze.tiles[coords]
  end

  defp follow_pipe_to_start(maze, current_tile, previous_coords) do
    next_tile =
      current_tile
      |> Tile.get_connecting_coords()
      |> Enum.find_value(fn coords ->
        tile = get_tile(maze, coords)

        if tile != nil and coords != previous_coords and
             Tile.connects_to?(tile, current_tile.coords) do
          tile
        end
      end)

    cond do
      next_tile == nil ->
        :error

      next_tile.type == :start ->
        [current_tile]

      true ->
        [current_tile | follow_pipe_to_start(maze, next_tile, current_tile.coords)]
    end
  end

  # Returns list of coordinate tuples starting
  def get_main_pipe(maze) do
    follow_pipe_to_start(maze, get_tile(maze, maze.starting_coords), nil)
  end
end

defmodule Day10 do
  defp process_input(input_string) do
    maze = Maze.parse(input_string)

    maze
    |> Maze.get_printable_maze()
    |> IO.puts()

    main_pipe_max_distance =
      Maze.get_main_pipe(maze)
      |> length()
      |> div(2)

    %{
      part1: main_pipe_max_distance,
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

Day10.main("input.txt")
