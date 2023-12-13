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

  # Returns %{cards: "AAAAA", bid: 12345, classification: :five_of_a_kind}
  defp classify_hand(hand) do
    frequencies =
      hand.cards
      |> String.graphemes()
      |> Enum.frequencies()
      |> Map.to_list()
      |> Enum.sort_by(fn {_, count} -> count end, :desc)

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

  defp classify_hands(hands) do
    hands
    |> Enum.map(&classify_hand/1)
  end

  # Returns true if card1 >= card2
  defp compare_cards(card1, card2) do
    @card_values[card1] >= @card_values[card2]
  end

  # Returns true if cards1 >= cards2
  defp compare_hand_cards(cards1, cards2) do
    unique_cards =
      Enum.zip(String.graphemes(cards1), String.graphemes(cards2))
      |> Enum.reject(fn {c1, c2} -> c1 == c2 end)

    case unique_cards do
      [] ->
        true

      _ ->
        {card1, card2} = List.first(unique_cards)
        compare_cards(card1, card2)
    end
  end

  # Returns true if kind1 >= kind2
  defp compare_kinds(kind1, kind2) do
    @kind_values[kind1] >= @kind_values[kind2]
  end

  # Returns true if hand1 >= hand2
  defp compare_hands(hand1, hand2) do
    cond do
      hand1.kind == hand2.kind ->
        compare_hand_cards(hand1.cards, hand2.cards)

      true ->
        compare_kinds(hand1.kind, hand2.kind)
    end
  end

  defp rank_hands(hands) do
    hands
    |> Enum.sort(&compare_hands/2)
    |> Enum.zip_with(Range.to_list(length(hands)..1), fn hand, rank ->
      Map.put(hand, :rank, rank)
    end)
  end

  defp process_input(input_string) do
    total_winnings =
      input_string
      |> parse_hands()
      |> classify_hands()
      |> rank_hands()
      |> Enum.map(fn hand -> hand.bid * hand.rank end)
      |> Enum.sum()

    %{
      part1: total_winnings,
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
          IO.puts("unable to read" <> path <> "\nexiting..."),
          exit({:shutdown, 1})
        }
    end
  end
end

Day7.main("input.txt")
