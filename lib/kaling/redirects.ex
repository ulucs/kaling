defmodule Kaling.Redirects do
  @moduledoc """
  The Redirects context.
  """

  import Ecto.Query, warn: false
  import Kaling.Hashing
  import Kaling.Monad
  alias Kaling.Repo

  alias Kaling.Redirects.Redirect
  alias Kaling.Accounts.User

  @doc """
  Resolves the redirect resource from the given `%Redirect{}` struct.
  """
  def resolve_redirect(%Redirect{} = redirect) do
    redirect
    |> Map.put(
      :short_url,
      KalingWeb.Endpoint.url() <> "/r/" <> encode(redirect.id)
    )
  end

  @doc """
  Returns the list of redirects.

  ## Examples

      iex> list_redirects(user)
      [%Redirect{}, ...]

  """
  def list_redirects(%User{} = user) do
    Redirect
    |> where([r], r.user_id == ^user.id)
    |> Repo.all()
    |> Enum.map(&resolve_redirect/1)
  end

  @doc """
  Gets a single redirect.

  Raises `Ecto.NoResultsError` if the Redirect does not exist.

  ## Examples

      iex> get_redirect!(123, user)
      %Redirect{}

      iex> get_redirect!(456, user)
      ** (Ecto.NoResultsError)

  """
  def get_redirect!(id, %User{} = user) do
    Redirect
    |> where([r], r.user_id == ^user.id)
    |> Repo.get!(id)
    |> resolve_redirect()
  end

  @doc """
  Gets a single redirect by its hashed id.

  Raises `Ecto.NoResultsError` if the Redirect does not exist.

  ## Examples

      iex> get_hashed_redirect!("abc")
      %Redirect{}

      iex> get_hashed_redirect!("def")
      ** (Ecto.NoResultsError)

  """
  def get_hashed_redirect!(hashed_id) do
    Redirect
    |> Repo.get!(decode!(hashed_id))
    |> resolve_redirect()
  end

  @doc """
  Creates a redirect.

  ## Examples

      iex> create_redirect(user, %{field: value})
      {:ok, %Redirect{}}

      iex> create_redirect(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_redirect(%User{} = user, attrs \\ %{}) do
    %Redirect{}
    |> Redirect.changeset(user, attrs)
    |> Repo.insert()
    |> e_map(&resolve_redirect/1)
  end

  @doc """
  Updates a redirect.

  ## Examples

      iex> update_redirect(redirect, user, %{field: new_value})
      {:ok, %Redirect{}}

      iex> update_redirect(redirect, user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_redirect(%Redirect{} = redirect, %User{} = user, attrs) do
    if redirect.user_id == user.id do
      redirect
      |> Redirect.changeset(user, attrs)
      |> Repo.update()
      |> e_map(&resolve_redirect/1)
    else
      {:error, "You are not authorized to update this redirect."}
    end
  end

  @doc """
  Deletes a redirect.

  ## Examples

      iex> delete_redirect(redirect, user)
      {:ok, %Redirect{}}

      iex> delete_redirect(redirect, user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_redirect(%Redirect{} = redirect, %User{} = user) do
    if redirect.user_id == user.id do
      Repo.delete(redirect)
    else
      {:error, "You are not authorized to delete this redirect."}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking redirect changes.

  ## Examples

      iex> change_redirect(redirect, user)
      %Ecto.Changeset{data: %Redirect{}}

  """
  def change_redirect(%Redirect{} = redirect, user, attrs \\ %{}) do
    Redirect.changeset(redirect, user, attrs)
  end
end
