defmodule Kaling.Redirects.Redirect do
  alias Kaling.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "redirects" do
    field :redirect_to, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(redirect, attrs) do
    redirect
    |> cast(attrs, [:redirect_to])
    |> validate_required([:redirect_to])
  end
end
