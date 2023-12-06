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

  defp get_matching_number_count(card) do
    card.numbers
    |> MapSet.intersection(card.winning_numbers)
    |> MapSet.size()
  end

  # Calculate points for card
  defp calculate_card_value(card) do
    card
    |> get_matching_number_count()
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

  # Zip two integer lists together, taking the sum of each indexes values
  defp zip_sum(list1, list2) do
    max_length = max(length(list1), length(list2))
    padded_list1 = list1 ++ List.duplicate(0, max_length - length(list1))
    padded_list2 = list2 ++ List.duplicate(0, max_length - length(list2))
    Enum.zip_with(padded_list1, padded_list2, fn x, y -> x + y end)
  end

  defp do_get_card_copy_count([], _) do
    0
  end

  # Return copies of cards using the upcoming card copies
  defp do_get_card_copy_count(cards, copy_counts) do
    [current_copy_count | rest_copy_counts] = copy_counts
    [card | rest_cards] = cards

    current_card_matches = get_matching_number_count(card)
    new_upcoming_copies = List.duplicate(current_copy_count, current_card_matches)

    combined_upcoming_copies = zip_sum(rest_copy_counts, new_upcoming_copies)
    current_copy_count + do_get_card_copy_count(rest_cards, combined_upcoming_copies)
  end

  # Process cards, adding copies of subsequent cards according to winning numbers
  defp get_card_copy_count(cards) do
    # start with one copy per card
    initial_copy_counts = List.duplicate(1, length(cards))
    do_get_card_copy_count(cards, initial_copy_counts)
  end

  defp process_input(scratchie_table) do
    cards =
      scratchie_table
      |> to_lines()
      |> parse_cards()

    point_total =
      cards
      |> calculate_card_values()
      |> Enum.sum()

    card_copy_total =
      cards
      |> get_card_copy_count()

    %{
      part1: point_total,
      part2: card_copy_total
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
