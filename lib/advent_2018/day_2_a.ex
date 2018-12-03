defmodule Advent2018.Day2A do
  def checksum(input) do
    twos_count(input) * threes_count(input)
  end

  def twos_count(input) do
    input
    |> String.split()
    |> Enum.count(&two?(&1))
  end

  def threes_count(input) do
    input
    |> String.split()
    |> Enum.count(&three?(&1))
  end

  def two?(box_id) do
    box_id
    |> counts()
    |> Enum.member?(2)
  end

  def three?(box_id) do
    box_id
    |> counts()
    |> Enum.member?(3)
  end

  defp counts(box_id) do
    box_id
    |> String.graphemes()
    |> Enum.group_by(& &1)
    |> Map.values()
    |> Enum.map(&Enum.count/1)
  end
end