defmodule Day4 do
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
    total =
      input
      |> get_letter_grid()
      |> count_xmas()

    %{
      part1: total,
      part2: nil
    }
  end

  defp get_letter_grid(wordsearch_string) do
    wordsearch_string
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
  end

  defp count_xmas(letter_grid) do
    letter_grid
    |> get_grid_locations()
    |> Enum.map(fn {row_index, col_index} ->
      count_xmas_from_location(letter_grid, row_index, col_index)
    end)
    |> Enum.sum()
  end

  defp get_grid_locations(letter_grid) do
    letter_grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {_letter, col_index} -> {row_index, col_index} end)
    end)
    |> List.flatten()
  end

  defp count_xmas_from_location(letter_grid, row_index, col_index) do
    [
      is_right_xmas(letter_grid, row_index, col_index),
      is_down_right_xmas(letter_grid, row_index, col_index),
      is_down_xmas(letter_grid, row_index, col_index),
      is_down_left_xmas(letter_grid, row_index, col_index),
      is_left_xmas(letter_grid, row_index, col_index),
      is_up_left_xmas(letter_grid, row_index, col_index),
      is_up_xmas(letter_grid, row_index, col_index),
      is_up_right_xmas(letter_grid, row_index, col_index)
    ]
    |> Enum.count(fn x -> x == true end)
  end

  defp is_right_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index, col_index + 1, "M") &&
      letter_at_location(letter_grid, row_index, col_index + 2, "A") &&
      letter_at_location(letter_grid, row_index, col_index + 3, "S")
  end

  defp is_down_right_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index + 1, col_index + 1, "M") &&
      letter_at_location(letter_grid, row_index + 2, col_index + 2, "A") &&
      letter_at_location(letter_grid, row_index + 3, col_index + 3, "S")
  end

  defp is_down_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index + 1, col_index, "M") &&
      letter_at_location(letter_grid, row_index + 2, col_index, "A") &&
      letter_at_location(letter_grid, row_index + 3, col_index, "S")
  end

  defp is_down_left_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index + 1, col_index - 1, "M") &&
      letter_at_location(letter_grid, row_index + 2, col_index - 2, "A") &&
      letter_at_location(letter_grid, row_index + 3, col_index - 3, "S")
  end

  defp is_left_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index, col_index - 1, "M") &&
      letter_at_location(letter_grid, row_index, col_index - 2, "A") &&
      letter_at_location(letter_grid, row_index, col_index - 3, "S")
  end

  defp is_up_left_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index - 1, col_index - 1, "M") &&
      letter_at_location(letter_grid, row_index - 2, col_index - 2, "A") &&
      letter_at_location(letter_grid, row_index - 3, col_index - 3, "S")
  end

  defp is_up_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index - 1, col_index, "M") &&
      letter_at_location(letter_grid, row_index - 2, col_index, "A") &&
      letter_at_location(letter_grid, row_index - 3, col_index, "S")
  end

  defp is_up_right_xmas(letter_grid, row_index, col_index) do
    letter_at_location(letter_grid, row_index, col_index, "X") &&
      letter_at_location(letter_grid, row_index - 1, col_index + 1, "M") &&
      letter_at_location(letter_grid, row_index - 2, col_index + 2, "A") &&
      letter_at_location(letter_grid, row_index - 3, col_index + 3, "S")
  end

  defp letter_at_location(letter_grid, row_index, col_index, letter) do
    cond do
      row_index < 0 ->
        false

      col_index < 0 ->
        false

      row_index >= Enum.count(letter_grid) ->
        false

      col_index >= Enum.count(Enum.at(letter_grid, row_index)) ->
        false

      true ->
        Enum.at(Enum.at(letter_grid, row_index), col_index) == letter
    end
  end
end

Day4.main("input.txt")
