defmodule Day1 do
  # Split string into list of lines
  def to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  def is_digit(string) do
    case Integer.parse(string) do
      :error -> false
      _ -> true
    end
  end

  # Return list of digits (integer or spelled) from string
  def filter_digits(line) do
    line
    |> String.split("", trim: true)
    |> Enum.filter(&is_digit/1)
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
