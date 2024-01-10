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
  def changeset(redirect, user, attrs) do
    redirect
    |> cast(attrs, [:redirect_to])
    |> cast(%{user_id: user.id}, [:user_id])
    |> validate_required([:redirect_to, :user_id])
  end
end
