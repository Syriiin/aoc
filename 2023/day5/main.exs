defmodule AlmanacMappingRule do
  @enforce_keys [:source_range, :destination_range]
  defstruct [:source_range, :destination_range]

  def new(source_start, destination_start, range_length) do
    %AlmanacMappingRule{
      source_range: source_start..(source_start + (range_length - 1)),
      destination_range: destination_start..(destination_start + (range_length - 1))
    }
  end

  # Returns {parsed mapping rule, remaining lines}
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
  def in_range?(rule, value) do
    rule.source_range.first <= value and value <= rule.source_range.last
  end

  # Return whether passed value is a subset of source range
  def is_subset?(rule, range) do
    in_range?(rule, range.first) and in_range?(rule, range.last)
  end

  # Return whether passed value is a superset of source range
  def is_superset?(rule, range) do
    not (in_range?(rule, range.first) or in_range?(rule, range.last))
  end

  # Return transformation offset
  defp offset(rule) do
    rule.destination_range.first - rule.source_range.first
  end

  def transform_value(nil, input_value) do
    input_value
  end

  # Map value from source to destination range, nil if out of range
  def transform_value(rule, input_value) do
    input_value + offset(rule)
  end

  defp transform_range(_, []) do
    {[], []}
  end

  # Return {transformed_ranges, untransformed_ranges} from input range
  # TODO: clean this up. don't need conditions for all cases, but maybe its more clear this way.
  defp transform_range(rule, input_range) do
    cond do
      # disjoint
      Range.disjoint?(input_range, rule.source_range) ->
        {[], [input_range]}

      # subset
      is_subset?(rule, input_range) ->
        transformed_range = Range.shift(input_range, offset(rule))
        {[transformed_range], []}

      # intersect start
      not in_range?(rule, input_range.first) and in_range?(rule, input_range.last) ->
        range_start_difference = rule.source_range.first - input_range.first
        {outrange, inrange} = Range.split(input_range, range_start_difference)
        transformed_range = Range.shift(inrange, offset(rule))
        {[transformed_range], [outrange]}

      # intersect end
      in_range?(rule, input_range.first) and not in_range?(rule, input_range.last) ->
        range_end_difference = rule.source_range.last - input_range.last
        {inrange, outrange} = Range.split(input_range, range_end_difference)
        transformed_range = Range.shift(inrange, offset(rule))
        {[transformed_range], [outrange]}

      # superset
      is_superset?(rule, input_range) ->
        range_start_difference = rule.source_range.first - input_range.first
        range_end_difference = rule.source_range.last - input_range.last
        {outrange_start, inrange} = Range.split(input_range, range_start_difference)
        {inrange, outrange_end} = Range.split(inrange, range_end_difference)
        transformed_range = Range.shift(inrange, offset(rule))
        {[transformed_range], [outrange_start, outrange_end]}
    end
  end

  # Return {transformed_ranges, untransformed_ranges} from [input_ranges]
  def transform_ranges(rule, input_ranges) do
    transformed_ranges =
      input_ranges
      |> Enum.map(fn input_range ->
        transform_range(rule, input_range)
      end)

    {transformed, untransformed} = Enum.unzip(transformed_ranges)
    {List.flatten(transformed), List.flatten(untransformed)}
  end
end

defmodule AlmanacMapping do
  @enforce_keys [:source, :destination, :ranges]
  defstruct [:source, :destination, :ranges]

  defp parse_mapping_rules([]) do
    {[], []}
  end

  # Return {parsed mapping rules, remaining lines}
  defp parse_mapping_rules(lines) do
    case AlmanacMappingRule.parse(lines) do
      {mapping_rule, remaining_lines} ->
        {mapping_rules, remaining_lines} = parse_mapping_rules(remaining_lines)
        {[mapping_rule | mapping_rules], remaining_lines}

      :error ->
        {[], lines}
    end
  end

  # Return {parsed mapping, remaining lines}
  def parse(lines) do
    [line | rest_lines] = lines

    case Regex.named_captures(~r/(?<source>\w+)-to-(?<destination>\w+) map:/, line) do
      %{"source" => source, "destination" => destination} ->
        {ranges, remaining_lines} = parse_mapping_rules(rest_lines)

        {%AlmanacMapping{source: source, destination: destination, ranges: ranges},
         remaining_lines}

      _ ->
        {nil, lines}
    end
  end

  # Map value using ranges
  def transform_value(mapping, input_value) do
    mapping.ranges
    |> Enum.find(fn r -> AlmanacMappingRule.in_range?(r, input_value) end)
    |> AlmanacMappingRule.transform_value(input_value)
  end

  # Return [transformed ranges] from [input ranges]
  # TODO: rewrite this, it feels terrible
  def transform_ranges(mapping, input_ranges) do
    {transformed_ranges, untransformed_ranges} =
      Enum.reduce(mapping.ranges, {[], input_ranges}, fn mapping_rule,
                                                         {transformed_ranges_acc,
                                                          input_ranges_acc} ->
        {transformed, untransformed} =
          AlmanacMappingRule.transform_ranges(mapping_rule, input_ranges_acc)

        {transformed ++ transformed_ranges_acc, untransformed}
      end)

    (transformed_ranges ++ untransformed_ranges)
    |> Enum.reject(&(&1 == []))
  end
end

defmodule Almanac do
  defstruct part1_seeds: [], part2_seed_ranges: [], mappings: []

  # Return list of seeds
  defp parse_almanac_seeds(seed_line) do
    "seeds: " <> seeds_string = seed_line

    seeds_string
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_almanac_mappings([]) do
    []
  end

  # Return parsed mappings and remaining lines
  defp parse_almanac_mappings(mapping_lines) do
    case AlmanacMapping.parse(mapping_lines) do
      {almanac_map, remaining_lines} -> [almanac_map | parse_almanac_mappings(remaining_lines)]
      :error -> []
    end
  end

  # Calculate seed ranged given list of part 1 seeds
  defp calculate_part2_seed_ranges(seeds) do
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x | [y]] -> x..(x + (y - 1)) end)
    |> List.flatten()
  end

  # Parse almanac string into Almanac struct
  def parse(almanac_string) do
    [seed_line | mapping_lines] = String.split(almanac_string, "\n", trim: true)

    seeds = parse_almanac_seeds(seed_line)

    %Almanac{
      part1_seeds: seeds,
      part2_seed_ranges: calculate_part2_seed_ranges(seeds),
      mappings: parse_almanac_mappings(mapping_lines)
    }
  end

  # Return location for seed by passing through mappings
  def location(almanac, seed) do
    Enum.reduce(almanac.mappings, seed, fn map, acc ->
      AlmanacMapping.transform_value(map, acc)
    end)
  end

  def lowest_location(_, []) do
    :error
  end

  # Return lowest location out of given seed values
  def lowest_location(almanac, seeds) do
    seeds
    |> Enum.map(fn s -> location(almanac, s) end)
    |> Enum.min()
  end

  # Return lowest location out of given seed ranges by reducing through mappings transforms
  def lowest_location_in_ranges(almanac, seed_ranges) do
    almanac.mappings
    |> Enum.reduce(seed_ranges, fn mapping, seed_ranges_acc ->
      AlmanacMapping.transform_ranges(mapping, seed_ranges_acc)
    end)
    |> Enum.map(fn r -> r.first end)
    |> Enum.min()
  end
end

defmodule Day5 do
  defp process_input(almanac_string) do
    almanac = Almanac.parse(almanac_string)

    %{
      part1: Almanac.lowest_location(almanac, almanac.part1_seeds),
      part2: Almanac.lowest_location_in_ranges(almanac, almanac.part2_seed_ranges)
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
