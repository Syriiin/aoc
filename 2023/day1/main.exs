defmodule Day1 do
  # Split string into list of lines
  def to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  # Return list of digits in the string, transforming spelled digits to numeric representation
  def get_digits(string) do
    case string do
      "1" <> _ -> ["1" | get_digits(String.slice(string, 1..-1))]
      "2" <> _ -> ["2" | get_digits(String.slice(string, 1..-1))]
      "3" <> _ -> ["3" | get_digits(String.slice(string, 1..-1))]
      "4" <> _ -> ["4" | get_digits(String.slice(string, 1..-1))]
      "5" <> _ -> ["5" | get_digits(String.slice(string, 1..-1))]
      "6" <> _ -> ["6" | get_digits(String.slice(string, 1..-1))]
      "7" <> _ -> ["7" | get_digits(String.slice(string, 1..-1))]
      "8" <> _ -> ["8" | get_digits(String.slice(string, 1..-1))]
      "9" <> _ -> ["9" | get_digits(String.slice(string, 1..-1))]
      "one" <> _ -> ["1" | get_digits(String.slice(string, 1..-1))]
      "two" <> _ -> ["2" | get_digits(String.slice(string, 1..-1))]
      "three" <> _ -> ["3" | get_digits(String.slice(string, 1..-1))]
      "four" <> _ -> ["4" | get_digits(String.slice(string, 1..-1))]
      "five" <> _ -> ["5" | get_digits(String.slice(string, 1..-1))]
      "six" <> _ -> ["6" | get_digits(String.slice(string, 1..-1))]
      "seven" <> _ -> ["7" | get_digits(String.slice(string, 1..-1))]
      "eight" <> _ -> ["8" | get_digits(String.slice(string, 1..-1))]
      "nine" <> _ -> ["9" | get_digits(String.slice(string, 1..-1))]
      "" -> []
      _ -> get_digits(String.slice(string, 1..-1))
    end
  end

  # Return list of digits (integer or spelled) from string
  def filter_digits(line) do
    get_digits(line)
  end

  # Return line value from list of digits
  def to_line_number(digit_list) do
    String.to_integer(List.first(digit_list) <> List.last(digit_list))
  end

  # Return list of values from line string
  def to_line_numbers(line_list) do
    line_list
    |> Enum.map(&filter_digits/1)
    |> Enum.map(&to_line_number/1)
  end

  def process_input(input) do
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
