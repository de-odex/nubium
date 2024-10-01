defmodule Nubium.Repo do
  use Ecto.Repo,
    otp_app: :nubium,
    adapter: Ecto.Adapters.SQLite3
end
