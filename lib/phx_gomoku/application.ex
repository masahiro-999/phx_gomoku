defmodule PhxGomoku.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhxGomokuWeb.Telemetry,
      # Start the Ecto repository
      PhxGomoku.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhxGomoku.PubSub},
      # Start Finch
      {Finch, name: PhxGomoku.Finch},
      # Start the Endpoint (http/https)
      PhxGomokuWeb.Endpoint
      # Start a worker by calling: PhxGomoku.Worker.start_link(arg)
      # {PhxGomoku.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxGomoku.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxGomokuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
