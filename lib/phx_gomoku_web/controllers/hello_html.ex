defmodule PhxGomokuWeb.HelloHTML do
  use PhxGomokuWeb, :html

  def index(assigns) do
    ~H"""
    Hello!Hello!
    """
  end

  # embed_templates "hello_html/*"
end
