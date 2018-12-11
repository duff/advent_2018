defmodule Advent2018.Day8Test do
  use ExUnit.Case, async: true

  alias Advent2018.Day8
  alias Advent2018.Day8.Tree

  test "simple tree with no children" do
    input = "0 3 2 3 4"

    assert Day8.tree(input) ==
             %Tree{
               children: [],
               meta: [2, 3, 4]
             }
  end

  test "tree with one child" do
    input = "1 2 0 3 2 3 4 5 6"

    assert Day8.tree(input) ==
             %Tree{
               children: [
                 %Tree{
                   children: [],
                   meta: [2, 3, 4]
                 }
               ],
               meta: [5, 6]
             }
  end

  test "tree" do
    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    assert Day8.tree(input) ==
             %Tree{
               children: [
                 %Tree{
                   children: [],
                   meta: [10, 11, 12]
                 },
                 %Tree{
                   children: [
                     %Tree{
                       children: [],
                       meta: [99]
                     }
                   ],
                   meta: [2]
                 }
               ],
               meta: [1, 1, 2]
             }
  end

  test "metadata_sum" do
    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
    assert Day8.metadata_sum(input) == 138
  end

  test "root_node_value" do
    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
    assert Day8.root_node_value(input) == 66
  end

  @tag :real
  test "metadata_sum real" do
    input = File.read!("test/lib/advent_2018/input/day8.txt") |> String.trim()
    assert Day8.metadata_sum(input) == 44338
  end

  @tag :real
  test "root_node_value real" do
    input = File.read!("test/lib/advent_2018/input/day8.txt") |> String.trim()
    assert Day8.root_node_value(input) == 37560
  end
end