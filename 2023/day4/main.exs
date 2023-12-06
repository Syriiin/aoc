defmodule Day4 do
  # Split string into list of lines
  defp to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  # Parse card scratchie table line into card
  defp parse_card(line) do
    [card_header | [rest]] = String.split(line, ": ", parts: 2)
    [<<"Card">>, <<id::binary>>] = String.split(card_header)
    [numbers_string | [winning_numbers_string]] = String.split(rest, " | ", parts: 2)
    numbers = String.split(numbers_string, " ", trim: true)
    winning_numbers = String.split(winning_numbers_string, " ", trim: true)

    %{
      id: String.to_integer(id),
      numbers: MapSet.new(Enum.map(numbers, &String.to_integer/1)),
      winning_numbers: MapSet.new(Enum.map(winning_numbers, &String.to_integer/1))
    }
  end

  # Parse scratchie table into cards
  defp parse_cards(scratchie_table_lines) do
    scratchie_table_lines
    |> Enum.map(&parse_card/1)
  end

  # Calculate points for card
  defp calculate_card_value(card) do
    MapSet.intersection(card.numbers, card.winning_numbers)
    |> MapSet.size()
    |> case do
      0 -> 0
      n -> 2 ** (n - 1)
    end
  end

  # Calculate points for all cards
  defp calculate_card_values(cards) do
    cards
    |> Enum.map(&calculate_card_value/1)
  end

  defp process_input(scratchie_table) do
    point_total =
      scratchie_table
      |> to_lines()
      |> parse_cards()
      |> calculate_card_values()
      |> Enum.sum()

    %{
      part1: point_total,
      part2: nil
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

Day4.main("input.txt")
