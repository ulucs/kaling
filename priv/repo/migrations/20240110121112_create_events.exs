defmodule Kaling.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :ip, :string
      add :headers, :map
      add :cookies, :map
      add :redirected_from, :string
      add :redirect_to, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :created_at, :utc_datetime
    end
  end
end
