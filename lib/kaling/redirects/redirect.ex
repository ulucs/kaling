defmodule Kaling.Redirects.Redirect do
  alias Kaling.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          redirect_to: String.t(),
          short_url: String.t(),
          user_id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "redirects" do
    field :redirect_to, :string
    field :short_url, :string, virtual: true

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
