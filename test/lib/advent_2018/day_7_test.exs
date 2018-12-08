defmodule Advent2018.Day7Test do
  use ExUnit.Case, async: true

  alias Advent2018.Day7

  test "order" do
    input = """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """

    assert Day7.order(input) == "CABDFE"
  end
end
