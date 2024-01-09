defmodule Kaling.Repo.Migrations.CreateRedirects do
  use Ecto.Migration

  def change do
    create table(:redirects) do
      add :redirect_to, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:redirects, [:user_id])
  end
end
