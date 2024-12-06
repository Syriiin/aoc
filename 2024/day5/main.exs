defmodule Day5 do
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

  defp process_input(input) do
    {rules, updates} = parse_input(input)

    correctly_ordered_update_middle_page_sum =
      updates
      |> Enum.filter(fn update -> is_update_correctly_ordered?(update, rules) end)
      |> Enum.map(&get_middle_page/1)
      |> Enum.sum()

    %{
      part1: correctly_ordered_update_middle_page_sum,
      part2: nil
    }
  end

  defp parse_input(input) do
    {rules_section, updates_section} =
      input
      |> String.split("\n\n", trim: true)
      |> List.to_tuple()

    {
      parse_rules(rules_section),
      parse_updates(updates_section)
    }
  end

  defp parse_rules(rules_section) do
    rules_section
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule_string) do
    {before_page, after_page} =
      rule_string
      |> String.split("|")
      |> List.to_tuple()

    {
      String.to_integer(before_page),
      String.to_integer(after_page)
    }
  end

  defp parse_updates(updates_section) do
    updates_section
    |> String.split("\n", trim: true)
    |> Enum.map(fn update_string ->
      update_string |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
  end

  defp is_update_correctly_ordered?(update, rules) do
    Enum.all?(rules, fn rule -> update_satisfies_rule?(update, rule) end)
  end

  defp update_satisfies_rule?(update, {before_page, after_page}) do
    before_page_index = Enum.find_index(update, fn p -> p == before_page end)
    after_page_index = Enum.find_index(update, fn p -> p == after_page end)

    before_page_index == nil or after_page_index == nil or before_page_index < after_page_index
  end

  defp get_middle_page(update) do
    page_count = Enum.count(update)
    Enum.at(update, floor(page_count / 2))
  end
end

Day5.main("input.txt")
