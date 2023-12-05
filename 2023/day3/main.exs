defmodule Day3 do
  defp do_parse_components(schematic, row, column) do
    case schematic do
      <<digit, _rest::binary>> when digit in ~c"0123456789" ->
        {number, _} = Integer.parse(schematic)
        number_length = length(Integer.digits(number))

        [
          %{
            type: :number,
            value: number,
            row_range: (row - 1)..(row + 1),
            column_range: (column - 1)..(column + number_length)
          }
          | do_parse_components(
              String.slice(schematic, number_length..-1),
              row,
              column + number_length
            )
        ]

      <<".", rest::binary>> ->
        do_parse_components(rest, row, column + 1)

      <<"\n", rest::binary>> ->
        do_parse_components(rest, row + 1, 0)

      <<_symbol, rest::binary>> ->
        [
          %{type: :symbol, row: row, column: column}
          | do_parse_components(rest, row, column + 1)
        ]

      "" ->
        []
    end
  end

  # Return list of maps per components: [%{type: :symbol, row: 0, column: 0}, %{type: :number, value: 823, row_range: 0..2, column_range: 0..4}]
  defp parse_components(schematic) do
    do_parse_components(schematic, 0, 0)
  end

  # Check if number is adjacent to any symbols by checking range overlaps
  defp is_part_number?(number, symbols) do
    Enum.any?(symbols, fn s -> s.row in number.row_range and s.column in number.column_range end)
  end

  # Find part numbers from collection of components
  defp get_part_numbers(components) do
    components.number
    |> Enum.filter(fn n -> is_part_number?(n, components.symbol) end)
  end

  # Get part number sum from schematic
  defp process_input(schematic) do
    schematic
    |> parse_components()
    |> Enum.group_by(fn m -> m.type end, fn m -> Map.pop(m, :type) |> elem(1) end)
    |> get_part_numbers()
    |> Enum.map(fn n -> n.value end)
    |> Enum.sum()
  end

  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        process_input(input)
        |> inspect(pretty: true)
        |> (&("Part 1 Answer: " <> &1)).()
        |> IO.puts()

      {:error, _} ->
        {
          IO.puts("unable to read input.txt. exiting..."),
          exit({:shutdown, 1})
        }
    end
  end
end

Day3.main("input.txt")
