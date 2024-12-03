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

    %{
      part1: safe_report_count,
      part2: nil
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
    is_safe_ascending_report(report) || is_safe_descending_report(report)
  end

  defp is_safe_ascending_report(report) do
    report
    |> Enum.chunk_every(2, 1)
    |> Enum.all?(&is_safe_ascending_level/1)
  end

  defp is_safe_ascending_level([x1, x2]) do
    x2 > x1 && x2 - x1 <= 3
  end

  defp is_safe_ascending_level([_x]) do
    true
  end

  defp is_safe_descending_report(report) do
    report
    |> Enum.chunk_every(2, 1)
    |> Enum.all?(&is_safe_descending_level/1)
  end

  defp is_safe_descending_level([x1, x2]) do
    x2 < x1 && x1 - x2 <= 3
  end

  defp is_safe_descending_level([_x]) do
    true
  end
end

Day2.main("input.txt")
