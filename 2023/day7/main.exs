defmodule Day7 do
  @kind_values %{
    :five_of_a_kind => 7,
    :four_of_a_kind => 6,
    :full_house => 5,
    :three_of_a_kind => 4,
    :two_pair => 3,
    :one_pair => 2,
    :high_card => 1
  }

  @card_values %{
    "A" => 13,
    "K" => 12,
    "Q" => 11,
    "J" => 10,
    "T" => 9,
    "9" => 8,
    "8" => 7,
    "7" => 6,
    "6" => 5,
    "5" => 4,
    "4" => 3,
    "3" => 2,
    "2" => 1
  }

  @card_values_part2 %{
    "A" => 13,
    "K" => 12,
    "Q" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2,
    "J" => 1
  }

  defp to_lines(input) do
    String.split(input, "\n", trim: true)
  end

  # Returns %{cards: "AAAAA", bid: 12345}
  defp parse_hand(hand_line) do
    [cards, bid_string] = String.split(hand_line, " ", trim: true)
    %{cards: cards, bid: String.to_integer(bid_string)}
  end

  defp parse_hands(raw_hands) do
    raw_hands
    |> to_lines()
    |> Enum.map(&parse_hand/1)
  end

  # Returns list of frequency tuples where jokers get absorbed into the highest count
  defp apply_wild_jokers(frequencies) do
    joker_count =
      Enum.find_value(frequencies, 0, fn {card, count} -> if card == "J", do: count end)

    jokerless_frequencies = Enum.reject(frequencies, fn {card, _} -> card == "J" end)

    case jokerless_frequencies do
      [{highest_card, highest_count} | rest_frequencies] ->
        [{highest_card, highest_count + joker_count} | rest_frequencies]

      [] ->
        frequencies
    end
  end

  # Returns %{cards: "AAAAA", bid: 12345, classification: :five_of_a_kind}
  defp classify_hand(hand, wild_jokers) do
    frequencies =
      hand.cards
      |> String.graphemes()
      |> Enum.frequencies()
      |> Map.to_list()
      |> Enum.sort_by(fn {_, count} -> count end, :desc)

    frequencies =
      if wild_jokers do
        apply_wild_jokers(frequencies)
      else
        frequencies
      end

    kind =
      case frequencies do
        [{_, 5}] -> :five_of_a_kind
        [{_, 4}, {_, 1}] -> :four_of_a_kind
        [{_, 3}, {_, 2}] -> :full_house
        [{_, 3}, {_, 1}, {_, 1}] -> :three_of_a_kind
        [{_, 2}, {_, 2}, {_, 1}] -> :two_pair
        [{_, 2}, {_, 1}, {_, 1}, {_, 1}] -> :one_pair
        [{_, 1}, {_, 1}, {_, 1}, {_, 1}, {_, 1}] -> :high_card
      end

    Map.put(hand, :kind, kind)
  end

  defp classify_hands(hands, wild_jokers \\ false) do
    hands
    |> Enum.map(fn h -> classify_hand(h, wild_jokers) end)
  end

  # Returns true if card1 >= card2
  defp compare_cards(card1, card2, card_values) do
    card_values[card1] >= card_values[card2]
  end

  # Returns true if cards1 >= cards2
  defp compare_hand_cards(cards1, cards2, card_values) do
    unique_cards =
      Enum.zip(String.graphemes(cards1), String.graphemes(cards2))
      |> Enum.reject(fn {c1, c2} -> c1 == c2 end)

    case unique_cards do
      [] ->
        true

      _ ->
        {card1, card2} = List.first(unique_cards)
        compare_cards(card1, card2, card_values)
    end
  end

  # Returns true if kind1 >= kind2
  defp compare_kinds(kind1, kind2) do
    @kind_values[kind1] >= @kind_values[kind2]
  end

  # Returns true if hand1 >= hand2
  defp compare_hands(hand1, hand2, card_values) do
    cond do
      hand1.kind == hand2.kind ->
        compare_hand_cards(hand1.cards, hand2.cards, card_values)

      true ->
        compare_kinds(hand1.kind, hand2.kind)
    end
  end

  defp rank_hands(hands, card_values) do
    hands
    |> Enum.sort(fn h1, h2 -> compare_hands(h1, h2, card_values) end)
    |> Enum.zip_with(Range.to_list(length(hands)..1), fn hand, rank ->
      Map.put(hand, :rank, rank)
    end)
  end

  defp calculate_total_winnings(hands) do
    hands
    |> Enum.map(fn hand -> hand.bid * hand.rank end)
    |> Enum.sum()
  end

  defp process_input(input_string) do
    hands =
      input_string
      |> parse_hands()

    total_winnings =
      hands
      |> classify_hands()
      |> rank_hands(@card_values)
      |> calculate_total_winnings()

    total_winnings_part2 =
      hands
      |> classify_hands(true)
      |> rank_hands(@card_values_part2)
      |> calculate_total_winnings()

    %{
      part1: total_winnings,
      part2: total_winnings_part2
    }
  end

  def main(path) do
    case File.read(path) do
      {:ok, input} ->
        result = process_input(input)

        IO.puts("Part 1 Answer: " <> inspect(result.part1, pretty: true))
        IO.puts("Part 2 Answer: " <> inspect(result.part2, pretty: true))

      {:error, _} ->
        IO.puts("unable to read" <> path <> "\nexiting...")
        System.halt(1)
    end
  end
end

Day7.main("input.txt")
