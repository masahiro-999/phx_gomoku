defmodule Gomoku do
  # alias __MODULE__ as Gomoku

  @enforce_keys [:board, :size]
  defstruct [:board, :size, :turn, :done, :draw, :miss, :k]

  def new(size, k) do
    board = for x <- 0..(size - 1), y <- 0..(size - 1), into: %{}, do: {{y, x}, 0}

    struct!(Gomoku, board: board, size: size, turn: 1, done: false, draw: false, miss: false, k: k)
  end

  def get_next_player(%Gomoku{turn: turn}) do
    turn
  end

  def can_put(%Gomoku{board: board}, {y, x}) do
    board[{y, x}] == 0
  end

  def get_leagal_actions(%Gomoku{size: size} = gomoku) do
    for y <- 0..(size - 1), x <- 0..(size - 1), can_put(gomoku, {y, x}), do: y * gomoku.size + x
  end

  def check_full(%Gomoku{size: size} = gomoku) do
    pos_list = for y <- 0..(size - 1), x <- 0..(size - 1), into: [], do: {y, x}

    Enum.reduce_while(pos_list, true, fn pos, _acc ->
      if can_put(gomoku, pos), do: {:halt, false}, else: {:cont, true}
    end)
  end

  def put!(%Gomoku{done: true} = gomoku, _) do
    gomoku
  end

  def put!(%Gomoku{done: false} = gomoku, action) when is_number(action) do
    put!(gomoku, action_to_xy(action, gomoku))
  end

  def put!(%Gomoku{board: board, turn: turn} = gomoku, {y, x}) do
    case board[{y, x}] do
      0 ->
        gomoku
        |> struct(board: %{board | {y, x} => turn})
        |> update_done({y, x})
        |> turn_player()

      _ ->
        struct(gomoku, miss: true, done: true)
    end
  end

  def action_to_xy(action, %Gomoku{size: size}) do
    x = rem(action, size)
    y = div(action, size)
    {y, x}
  end

  def turn_player(%Gomoku{done: true} = gomoku) do
    gomoku
  end

  def turn_player(%Gomoku{turn: turn, done: false} = gomoku) do
    struct!(gomoku, turn: next_player(turn))
  end

  def next_player(1), do: 2
  def next_player(_), do: 1

  def count_stones_within_n(_, _, _, _, acc \\ 0)

  def count_stones_within_n(%Gomoku{size: size}, {y, x}, {_dy, _dx}, n, acc)
      when x < 0 or x >= size or y < 0 or y >= size or n == 0 do
    acc
  end

  def count_stones_within_n(%Gomoku{board: board, turn: turn} = gomoku, {y, x}, {dy, dx}, n, acc) do
    cond do
      board[{y, x}] == turn ->
        count_stones_within_n(gomoku, {y + dy, x + dx}, {dy, dx}, n - 1, acc + 1)

      board[{y, x}] == 0 ->
        count_stones_within_n(gomoku, {y + dy, x + dx}, {dy, dx}, n - 1, acc)

      true ->
        acc
    end
  end

  def count_stones_within_5(gomoku, {y, x}, {dy, dx}, n) do
    side1 = count_stones_within_n(gomoku, {y + dy, x + dx}, {dy, dx}, n)
    side2 = count_stones_within_n(gomoku, {y - dy, x - dx}, {-dy, -dx}, 4 - n)
    myself = 1
    side1 + myself + side2
  end

  def count_stones_within_5(gomoku, pos, dydx) do
    for n <- 0..4 do
      count_stones_within_5(gomoku, pos, dydx, n)
    end
    |> Enum.max()
  end

  def count_stones_within_5(gomoku, pos) do
    for dydx <- [{0, 1}, {1, 0}, {1, 1}, {1, -1}] do
      count_stones_within_5(gomoku, pos, dydx)
    end
    |> Enum.max()
  end

  def count_same_value_continues(%Gomoku{size: size}, {y, x}, {_dy, _dx})
      when x < 0 or x >= size or y < 0 or y >= size do
    0
  end

  def count_same_value_continues(%Gomoku{board: board, turn: turn} = gomoku, {y, x}, {dy, dx}) do
    cond do
      board[{y, x}] == turn -> 1 + count_same_value_continues(gomoku, {y + dy, x + dx}, {dy, dx})
      true -> 0
    end
  end

  def count_same_value_continues_both_side(%Gomoku{} = gomoku, {y, x}, {dy, dx}) do
    side1 = count_same_value_continues(gomoku, {y + dy, x + dx}, {dy, dx})
    side2 = count_same_value_continues(gomoku, {y - dy, x - dx}, {-dy, -dx})
    myself = 1
    side1 + myself + side2
  end

  def update_done(%Gomoku{k: k} = gomoku, pos) do
    success =
      count_same_value_continues_both_side(gomoku, pos, {0, 1}) == k ||
        count_same_value_continues_both_side(gomoku, pos, {1, 1}) == k ||
        count_same_value_continues_both_side(gomoku, pos, {1, -1}) == k ||
        count_same_value_continues_both_side(gomoku, pos, {1, 0}) == k

    draw = check_full(gomoku) and not success

    done = draw or success

    struct!(gomoku, done: done, draw: draw)
  end

  def render_line(%Gomoku{board: board, size: size}, line) do
    for x <- 0..(size - 1), reduce: "#{line + 1}: " do
      acc -> acc <> to_display_char(board[{line, x}])
    end
  end

  def render(%Gomoku{size: size} = gomoku) do
    for y <- 0..(size - 1), reduce: "   abc\n" do
      acc -> acc <> render_line(gomoku, y) <> "\n"
    end

    # |> tap(&IO.puts(&1))
  end

  def to_display_char(value) do
    table = %{0 => "-", 1 => "○", 2 => "●"}
    table[value]
  end

  def to_array(%Gomoku{} = gomoku) do
    ally = to_array(gomoku, gomoku.turn)
    enemy = to_array(gomoku, next_player(gomoku.turn))
    [ally, enemy]
  end

  def to_array(%Gomoku{board: board, size: size}, target) do
    for y <- 0..(size - 1) do
      for x <- 0..(size - 1), do: if(board[{y, x}] == target, do: 1, else: 0)
    end
  end
end
