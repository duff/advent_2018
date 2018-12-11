defmodule Advent2018.Day9Test do
  use ExUnit.Case, async: true

  alias Advent2018.Day9

  test "score" do
    assert Day9.score(9, 25) == 32
    assert Day9.score(10, 1618) == 8317
    assert Day9.score(13, 7999) == 146_373
    assert Day9.score(17, 1104) == 2764
    assert Day9.score(21, 6111) == 54718
    assert Day9.score(30, 5807) == 37305
  end

  @tag :real
  test "score real" do
    assert Day9.score(455, 5807) == 0
  end
end
