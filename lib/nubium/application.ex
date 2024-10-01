defmodule Nubium.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NubiumWeb.Telemetry,
      Nubium.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:nubium, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:nubium, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Nubium.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Nubium.Finch},
      # Start a worker by calling: Nubium.Worker.start_link(arg)
      # {Nubium.Worker, arg},
      # Start to serve requests, typically the last entry
      NubiumWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nubium.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NubiumWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
