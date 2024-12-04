defmodule Day2 do
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
    reports =
      input
      |> to_lines()
      |> Enum.map(&to_report/1)

    safe_report_count =
      reports
      |> Enum.map(&is_safe_report/1)
      |> Enum.count(fn x -> x end)

    tolerant_safe_report_count =
      reports
      |> Enum.map(&is_tolerant_safe_report_brute/1)
      |> Enum.count(fn x -> x end)

    %{
      part1: safe_report_count,
      part2: tolerant_safe_report_count
    }
  end

  defp to_lines(string) do
    String.split(string, "\n", trim: true)
  end

  defp to_report(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp is_safe_report(report) do
    is_safe_levels(report) || is_safe_levels(Enum.reverse(report))
  end

  defp is_tolerant_safe_report_brute(report) do
    report
    |> get_one_missing_permutations()
    |> Enum.any?(&is_safe_report/1)
  end

  defp get_one_missing_permutations(levels) do
    0..(Enum.count(levels) - 1)
    |> Range.to_list()
    |> Enum.map(fn i -> levels_minus_value_at_index(levels, i) end)
  end

  defp levels_minus_value_at_index(levels, i) do
    {first, second} = Enum.split(levels, i)
    first ++ tl(second)
  end

  defp is_safe_levels([_]) do
    true
  end

  defp is_safe_levels([x1, x2 | rest_levels]) do
    is_safe_level_change(x1, x2) && is_safe_levels([x2 | rest_levels])
  end

  defp is_safe_level_change(x1, x2) do
    x2 > x1 && x2 - x1 <= 3
  end
end

Day2.main("input.txt")
