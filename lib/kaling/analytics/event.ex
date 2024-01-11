defmodule Kaling.Analytics.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          ip: String.t(),
          headers: map(),
          cookies: map(),
          redirected_from: String.t(),
          redirect_to: String.t(),
          user_id: integer(),
          created_at: DateTime.t()
        }

  schema "events" do
    field :ip, :string
    field :headers, :map
    field :cookies, :map

    # do not reference the redirect, because I don't want to keep a history of those
    # just grab the important bits as a snapshot
    field :redirected_from, :string
    field :redirect_to, :string
    belongs_to :user, Kaling.Accounts.User

    field :created_at, :utc_datetime
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:conn, :redirect, :created_at])
    |> validate_required([:conn, :redirect, :created_at])
  end
end
