defmodule Day1 do
  # Split string into list of lines
  defp to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  # Return list of digits in the string, transforming spelled digits to numeric representation
  defp get_digits(string) do
    get_tail_digits = fn s -> get_digits(String.slice(s, 1..-1)) end

    case string do
      "1" <> _ -> ["1" | get_tail_digits.(string)]
      "2" <> _ -> ["2" | get_tail_digits.(string)]
      "3" <> _ -> ["3" | get_tail_digits.(string)]
      "4" <> _ -> ["4" | get_tail_digits.(string)]
      "5" <> _ -> ["5" | get_tail_digits.(string)]
      "6" <> _ -> ["6" | get_tail_digits.(string)]
      "7" <> _ -> ["7" | get_tail_digits.(string)]
      "8" <> _ -> ["8" | get_tail_digits.(string)]
      "9" <> _ -> ["9" | get_tail_digits.(string)]
      "one" <> _ -> ["1" | get_tail_digits.(string)]
      "two" <> _ -> ["2" | get_tail_digits.(string)]
      "three" <> _ -> ["3" | get_tail_digits.(string)]
      "four" <> _ -> ["4" | get_tail_digits.(string)]
      "five" <> _ -> ["5" | get_tail_digits.(string)]
      "six" <> _ -> ["6" | get_tail_digits.(string)]
      "seven" <> _ -> ["7" | get_tail_digits.(string)]
      "eight" <> _ -> ["8" | get_tail_digits.(string)]
      "nine" <> _ -> ["9" | get_tail_digits.(string)]
      "" -> []
      _ -> get_tail_digits.(string)
    end
  end

  # Return list of digits (integer or spelled) from string
  defp filter_digits(line) do
    get_digits(line)
  end

  # Return line value from list of digits
  defp to_line_number(digit_list) do
    String.to_integer(List.first(digit_list) <> List.last(digit_list))
  end

  # Return list of values from line string
  defp to_line_numbers(line_list) do
    line_list
    |> Enum.map(&filter_digits/1)
    |> Enum.map(&to_line_number/1)
  end

  defp process_input(input) do
    input
    |> to_lines()
    |> to_line_numbers()
    |> Enum.sum()
  end

  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        process_input(input)
        |> inspect()
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

Day1.main("input.txt")
