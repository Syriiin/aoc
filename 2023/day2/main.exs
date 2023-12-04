defmodule Day2 do
  @red_count 12
  @green_count 13
  @blue_count 14

  # Split string into list of lines
  defp to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  # Return boolean indicating whether count for colour was possible or not
  defp colour_count_is_possible?(colour_string) do
    [count_string | [colour]] = String.split(colour_string)
    count = String.to_integer(count_string)

    case colour do
      "red" -> count <= @red_count
      "green" -> count <= @green_count
      "blue" -> count <= @blue_count
    end
  end

  # Return boolean indicating whether round was possible or not
  defp round_is_possible?(round_string) do
    round_string
    |> String.split(", ")
    |> Enum.all?(&colour_count_is_possible?/1)
  end

  # Return boolean indicating whether the line was possible or not
  defp game_is_possible?(line) do
    [_ | [game_string]] = String.split(line, ": ")

    game_string
    |> String.split("; ")
    |> Enum.all?(&round_is_possible?/1)
  end

  # Return game id from line
  defp to_line_value(line) do
    line
    |> String.split(": ")
    |> hd()
    |> String.slice(5..-1)
    |> String.to_integer()
  end

  # Return list of values from line string
  defp to_line_values(line_list) do
    line_list
    |> Enum.filter(&game_is_possible?/1)
    |> Enum.map(&to_line_value/1)
  end

  defp process_input(input) do
    input
    |> to_lines()
    |> to_line_values()
    |> Enum.sum()
  end

  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        process_input(input)
        |> inspect(pretty: true)
        |> (&("Answer: " <> &1)).()
        |> IO.puts()

      {:error, _} ->
        {
          IO.puts("unable to read input.txt. exiting..."),
          exit({:shutdown, 1})
        }
    end
  end
end

Day2.main("input.txt")
