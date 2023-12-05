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

      <<symbol, rest::binary>> ->
        [
          %{type: :symbol, symbol: <<symbol>>, row: row, column: column}
          | do_parse_components(rest, row, column + 1)
        ]

      "" ->
        []
    end
  end

  # Return list of maps per components: [%{type: :symbol, symbol: "*", row: 0, column: 0}, %{type: :number, value: 823, row_range: 0..2, column_range: 0..4}]
  defp parse_components(schematic) do
    components = do_parse_components(schematic, 0, 0)

    %{
      symbols: Enum.filter(components, fn c -> c.type == :symbol end),
      numbers: Enum.filter(components, fn c -> c.type == :number end)
    }
  end

  # Check if a given symbol and number are adjacent
  defp is_adjacent?(symbol, number) do
    symbol.row in number.row_range and symbol.column in number.column_range
  end

  # Check if number is adjacent to any symbols by checking range overlaps
  defp is_part_number?(number, symbols) do
    Enum.any?(symbols, fn s -> is_adjacent?(s, number) end)
  end

  # Find part numbers from collection of components
  defp get_part_numbers(components) do
    components.numbers
    |> Enum.filter(fn n -> is_part_number?(n, components.symbols) end)
  end

  # Get list of gears by checking adjacent numbers
  defp get_gears(symbols, numbers) do
    Enum.reduce(symbols, [], fn s, acc ->
      adjacent_numbers = Enum.filter(numbers, fn n -> is_adjacent?(s, n) end)

      case length(adjacent_numbers) do
        2 -> [%{gear: s, numbers: adjacent_numbers} | acc]
        _ -> acc
      end
    end)
  end

  # Calculate the gear ratio of a given gear
  defp get_gear_ratio(gear) do
    gear.numbers
    |> Enum.map(fn n -> n.value end)
    |> Enum.product()
  end

  # Get gear ratios from component map
  defp get_gear_ratios(components) do
    components.symbols
    |> get_gears(components.numbers)
    |> Enum.map(&get_gear_ratio/1)
  end

  # Get part number sum and gear ratio sum from schematic
  defp process_input(schematic) do
    components = parse_components(schematic)

    part_number_sum =
      components
      |> get_part_numbers()
      |> Enum.map(fn n -> n.value end)
      |> Enum.sum()

    gear_ratio_sum =
      components
      |> get_gear_ratios()
      |> Enum.sum()

    %{
      part1: part_number_sum,
      part2: gear_ratio_sum
    }
  end

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
end

Day3.main("input.txt")
