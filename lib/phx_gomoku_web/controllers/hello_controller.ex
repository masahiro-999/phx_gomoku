defmodule PhxGomokuWeb.HelloController do
  use PhxGomokuWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
