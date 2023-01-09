defmodule PhxGomokuWeb.GomokuLive do
  use PhxGomokuWeb, :live_view

  @num_row_col 5
  @win_condition 4
  @width 500
  def render(assigns) do
    ~H"""
    <div style={"display: grid;
                grid-template-columns: repeat(#{@board.size},#{@width/@board.size}px);
                grid-template-rows: repeat(#{@board.size},#{@width/@board.size}px);
                width: #{@width}px;
                height: #{@width}px;"}>
      <%= for {y, x, class_string} <- create_elements(@board) do %>
        <div class={class_string} phx-click="clicked" phx-value-x={x} phx-value-y={y}></div>
      <% end %>
    </div>
    <%= if @board.done do %>
      <.button phx-click="new_game">New Game</.button>
    <% end %>
    """
  end

  def create_elements(%Gomoku{size: size, board: board} = gomoku) do
    for y <- 0..(size - 1), x <- 0..(size - 1) do
      {y, x, get_class_string(board[{y, x}], gomoku)}
    end
  end

  def get_class_string(0, %Gomoku{done: true}), do: "cell"
  def get_class_string(0, %Gomoku{done: false, turn: 1}), do: "cell turn-white"
  def get_class_string(0, %Gomoku{done: false, turn: 2}), do: "cell turn-black"
  def get_class_string(1, _), do: "cell white"
  def get_class_string(2, _), do: "cell black"

  def new() do
    Gomoku.new(@num_row_col, @win_condition)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, board: new(), width: @width)}
  end

  def handle_event("clicked", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    {:noreply, update(socket, :board, &Gomoku.put!(&1, {y, x}))}
  end

  def handle_event("new_game", _, socket) do
    {:noreply, assign(socket, board: new())}
  end
end
