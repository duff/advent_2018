defmodule Advent2018.Day13.Railroad do
  defstruct tracks: %{}, trains: %{}, bottom_x: 0, bottom_y: 0, ticks: 0, first_collision_at: nil, more_than_one_train: true
end

defmodule Advent2018.Day13.Train do
  defstruct x: nil, y: nil, character: nil, next_direction: :left, moved_this_tick: false

  alias Advent2018.Day13.Train

  def new_position(%Train{character: ">", x: x, y: y, moved_this_tick: false} = train) do
    {:ok, {x + 1, y}, train}
  end

  def new_position(%Train{character: "<", x: x, y: y, moved_this_tick: false} = train) do
    {:ok, {x - 1, y}, train}
  end

  def new_position(%Train{character: "v", x: x, y: y, moved_this_tick: false} = train) do
    {:ok, {x, y + 1}, train}
  end

  def new_position(%Train{character: "^", x: x, y: y, moved_this_tick: false} = train) do
    {:ok, {x, y - 1}, train}
  end

  def new_position(_) do
    :no_train
  end

  def turn(%Train{character: "v"} = train, "/"), do: %Train{train | character: "<"}
  def turn(%Train{character: "v"} = train, "\\"), do: %Train{train | character: ">"}
  def turn(%Train{character: ">"} = train, "\\"), do: %Train{train | character: "v"}
  def turn(%Train{character: ">"} = train, "/"), do: %Train{train | character: "^"}
  def turn(%Train{character: "^"} = train, "\\"), do: %Train{train | character: "<"}
  def turn(%Train{character: "^"} = train, "/"), do: %Train{train | character: ">"}
  def turn(%Train{character: "<"} = train, "\\"), do: %Train{train | character: "^"}
  def turn(%Train{character: "<"} = train, "/"), do: %Train{train | character: "v"}

  def turn(%Train{character: "v", next_direction: :left} = t, "+"), do: %Train{t | character: ">", next_direction: :straight}
  def turn(%Train{character: ">", next_direction: :left} = t, "+"), do: %Train{t | character: "^", next_direction: :straight}
  def turn(%Train{character: "<", next_direction: :left} = t, "+"), do: %Train{t | character: "v", next_direction: :straight}
  def turn(%Train{character: "^", next_direction: :left} = t, "+"), do: %Train{t | character: "<", next_direction: :straight}
  def turn(%Train{character: "v", next_direction: :right} = t, "+"), do: %Train{t | character: "<", next_direction: :left}
  def turn(%Train{character: ">", next_direction: :right} = t, "+"), do: %Train{t | character: "v", next_direction: :left}
  def turn(%Train{character: "<", next_direction: :right} = t, "+"), do: %Train{t | character: "^", next_direction: :left}
  def turn(%Train{character: "^", next_direction: :right} = t, "+"), do: %Train{t | character: ">", next_direction: :left}

  def turn(%Train{next_direction: :straight} = t, "+"), do: %Train{t | next_direction: :right}

  def turn(train, _), do: train
end

defmodule Advent2018.Day13 do
  alias Advent2018.Day13.Railroad
  alias Advent2018.Day13.Train

  def part_a(input) do
    input
    |> initialize
    |> tick_until_collision
    |> collision_coordinates
  end

  def part_b(input) do
    input
    |> initialize
    |> tick_until_one_train_remaining
    |> last_train_coordinates
  end

  defp tick_until_collision(%Railroad{first_collision_at: nil} = railroad) do
    Enum.reduce(0..railroad.bottom_x, railroad, fn x, railroad ->
      Enum.reduce(0..railroad.bottom_y, railroad, fn y, railroad ->
        move_train_for_collision_check(railroad, {x, y})
      end)
    end)
    |> complete_tick
    |> tick_until_collision
  end

  defp tick_until_collision(railroad), do: railroad

  defp tick_until_one_train_remaining(%Railroad{more_than_one_train: true} = railroad) do
    Enum.reduce(0..railroad.bottom_x, railroad, fn x, railroad ->
      Enum.reduce(0..railroad.bottom_y, railroad, fn y, railroad ->
        move_train_exploding_collision(railroad, {x, y})
      end)
    end)
    |> complete_tick
    |> tick_until_one_train_remaining
  end

  defp tick_until_one_train_remaining(railroad), do: railroad

  defp collision_coordinates(%Railroad{first_collision_at: position}), do: position

  defp last_train_coordinates(%Railroad{trains: trains}) do
    trains
    |> Map.keys()
    |> hd
  end

  defp move_train_for_collision_check(railroad, coordinates) do
    case Train.new_position(train_at(railroad, coordinates)) do
      {:ok, new_position, train} ->
        railroad
        |> check_for_collision(new_position)
        |> actually_move_train(new_position, train)

      :no_train ->
        railroad
    end
  end

  defp move_train_exploding_collision(railroad, coordinates) do
    case Train.new_position(train_at(railroad, coordinates)) do
      {:ok, new_position, train} ->
        if train_at(railroad, new_position) do
          explode_trains(railroad, new_position, coordinates)
        else
          actually_move_train(railroad, new_position, train)
        end

      :no_train ->
        railroad
    end
  end

  defp explode_trains(%Railroad{trains: trains} = railroad, coordinates_one, coordinates_two) do
    new_trains =
      trains
      |> Map.delete(coordinates_one)
      |> Map.delete(coordinates_two)

    %{railroad | trains: new_trains, more_than_one_train: Enum.count(new_trains) > 1}
  end

  defp check_for_collision(%Railroad{first_collision_at: nil} = railroad, new_position) do
    if train_at(railroad, new_position) do
      %{railroad | first_collision_at: new_position}
    else
      railroad
    end
  end

  defp check_for_collision(railroad, _new_position) do
    railroad
  end

  defp actually_move_train(%Railroad{trains: trains} = railroad, new_coordinates, %Train{x: old_x, y: old_y} = train) do
    new_trains =
      trains
      |> Map.delete({old_x, old_y})
      |> Map.put(new_coordinates, move_and_turn(railroad, train, new_coordinates))

    %{railroad | trains: new_trains}
  end

  defp move_and_turn(railroad, train, coordinates) do
    train
    |> move_to(coordinates)
    |> Train.turn(track_at(railroad, coordinates))
  end

  defp move_to(train, {new_x, new_y}) do
    %Train{train | x: new_x, y: new_y, moved_this_tick: true}
  end

  defp complete_tick(%Railroad{trains: trains} = railroad) do
    new_trains =
      trains
      |> Enum.map(fn {coordinates, train} -> {coordinates, %Train{train | moved_this_tick: false}} end)
      |> Map.new()

    %{railroad | trains: new_trains, ticks: railroad.ticks + 1}
  end

  defp train_at(railroad, coordinates) do
    Map.get(railroad.trains, coordinates)
  end

  defp track_at(railroad, coordinates) do
    Map.get(railroad.tracks, coordinates)
  end

  defp put_track_and_train(railroad, coordinates, char) when char in [">", "<"] do
    railroad
    |> put_track(coordinates, "-")
    |> put_train(coordinates, char)
  end

  defp put_track_and_train(railroad, coordinates, char) when char in ["v", "^"] do
    railroad
    |> put_track(coordinates, "|")
    |> put_train(coordinates, char)
  end

  defp put_track_and_train(railroad, coordinates, character) do
    put_track(railroad, coordinates, character)
  end

  defp put_track(%Railroad{tracks: tracks} = railroad, coordinates, character) do
    %{railroad | tracks: Map.put(tracks, coordinates, character)}
  end

  defp put_train(%Railroad{trains: trains} = railroad, {x, y}, character) do
    %{railroad | trains: Map.put(trains, {x, y}, %Train{x: x, y: y, character: character})}
  end

  defp update_bottom_right(%Railroad{bottom_x: x, bottom_y: y} = railroad, {new_x, new_y}) do
    %{railroad | bottom_x: max(x, new_x), bottom_y: max(y, new_y)}
  end

  defp initialize(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%Railroad{}, fn {row, y}, railroad ->
      String.codepoints(row)
      |> Enum.with_index()
      |> Enum.reduce(railroad, fn {character, x}, railroad ->
        railroad
        |> put_track_and_train({x, y}, character)
        |> update_bottom_right({x, y})
      end)
    end)
  end
end
