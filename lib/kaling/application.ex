defmodule Kaling.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      KalingWeb.Telemetry,
      # Start the Ecto repository
      Kaling.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kaling.PubSub},
      # Start Finch
      {Finch, name: Kaling.Finch},
      # Start the Endpoint (http/https)
      KalingWeb.Endpoint
      # Start a worker by calling: Kaling.Worker.start_link(arg)
      # {Kaling.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kaling.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KalingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
