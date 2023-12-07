defmodule AlmanacMapRange do
  @enforce_keys [:source_range, :destination_range]
  defstruct [:source_range, :destination_range]

  def new(source_start, destination_start, range_length) do
    %AlmanacMapRange{
      source_range: source_start..(source_start + (range_length - 1)),
      destination_range: destination_start..(destination_start + (range_length - 1))
    }
  end

  def parse(lines) do
    [line | rest_lines] = lines

    case Regex.named_captures(~r/(?<destination>\d+) (?<source>\d+) (?<length>\d+)/, line) do
      %{"source" => source_start, "destination" => destination_start, "length" => range_length} ->
        {
          new(
            String.to_integer(source_start),
            String.to_integer(destination_start),
            String.to_integer(range_length)
          ),
          rest_lines
        }

      _ ->
        :error
    end
  end

  # Return whether passed value is within source range
  def in_range(range, value) do
    not Range.disjoint?(range.source_range, value..value)
  end

  def map_value(nil, source_value) do
    source_value
  end

  # Map value from source to destination range, nil if out of range
  def map_value(range, source_value) do
    source_range_start.._//_ = range.source_range
    destination_range_start.._//_ = range.destination_range
    offset = destination_range_start - source_range_start
    source_value + offset
  end
end

defmodule AlmanacMap do
  @enforce_keys [:source, :destination, :ranges]
  defstruct [:source, :destination, :ranges]

  defp parse_map_ranges([]) do
    {[], []}
  end

  defp parse_map_ranges(lines) do
    case AlmanacMapRange.parse(lines) do
      {almanac_map_range, remaining_lines} ->
        {rest_map_ranges, remaining_lines} = parse_map_ranges(remaining_lines)
        {[almanac_map_range | rest_map_ranges], remaining_lines}

      :error ->
        {[], lines}
    end
  end

  # Return parsed map and remaining lines
  def parse(lines) do
    [line | rest_lines] = lines

    case Regex.named_captures(~r/(?<source>\w+)-to-(?<destination>\w+) map:/, line) do
      %{"source" => source, "destination" => destination} ->
        {ranges, remaining_lines} = parse_map_ranges(rest_lines)
        {%AlmanacMap{source: source, destination: destination, ranges: ranges}, remaining_lines}

      _ ->
        {nil, lines}
    end
  end

  # Map value using ranges
  def map_value(map, source_value) do
    map.ranges
    |> Enum.find(fn r -> AlmanacMapRange.in_range(r, source_value) end)
    |> AlmanacMapRange.map_value(source_value)
  end
end

defmodule Almanac do
  defstruct part1_seeds: [], part2_seeds: [], maps: []

  # Return list of seeds
  defp parse_almanac_seeds(seed_line) do
    "seeds: " <> seeds_string = seed_line

    seeds_string
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_almanac_maps([]) do
    []
  end

  # Return parsed maps and remaining lines
  defp parse_almanac_maps(map_lines) do
    case AlmanacMap.parse(map_lines) do
      {almanac_map, remaining_lines} -> [almanac_map | parse_almanac_maps(remaining_lines)]
      :error -> []
    end
  end

  defp calculate_part2_seeds(seeds) do
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x | [y]] -> Range.to_list(x..(x + (y - 1))) end)
    |> List.flatten()
  end

  defp parse_almanac_lines(almanac_lines) do
    [seed_line | map_lines] = almanac_lines

    seeds = parse_almanac_seeds(seed_line)

    %Almanac{
      part1_seeds: seeds,
      part2_seeds: calculate_part2_seeds(seeds),
      maps: parse_almanac_maps(map_lines)
    }
  end

  def parse(almanac_string) do
    almanac_string
    |> String.split("\n", trim: true)
    |> parse_almanac_lines()
  end

  # Return location for seed by passing through maps
  def location(almanac, seed) do
    Enum.reduce(almanac.maps, seed, fn map, acc -> AlmanacMap.map_value(map, acc) end)
  end

  def lowest_location(_, []) do
    :error
  end

  def lowest_location(almanac, seeds) do
    seeds
    |> Enum.map(fn s -> location(almanac, s) end)
    |> Enum.min()
  end
end

defmodule Day5 do
  defp process_input(almanac_string) do
    almanac = Almanac.parse(almanac_string)

    %{
      part1: Almanac.lowest_location(almanac, almanac.part1_seeds),
      part2: Almanac.lowest_location(almanac, almanac.part2_seeds)
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

Day5.main("input.txt")
