defmodule Advent2018.Day01A do
  def calibrate(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer(&1))
    |> Enum.sum()
  end
end
