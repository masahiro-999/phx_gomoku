defmodule PhxGomoku.Repo do
  use Ecto.Repo,
    otp_app: :phx_gomoku,
    adapter: Ecto.Adapters.SQLite3
end
