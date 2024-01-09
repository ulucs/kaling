defmodule Kaling.Repo do
  use Ecto.Repo,
    otp_app: :kaling,
    adapter: Ecto.Adapters.Postgres
end
