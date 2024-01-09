defmodule Kaling.Redirects do
  @moduledoc """
  The Redirects context.
  """

  import Ecto.Query, warn: false
  alias Kaling.Repo

  alias Kaling.Redirects.Redirect

  @doc """
  Returns the list of redirects.

  ## Examples

      iex> list_redirects()
      [%Redirect{}, ...]

  """
  def list_redirects do
    Repo.all(Redirect)
  end

  @doc """
  Gets a single redirect.

  Raises `Ecto.NoResultsError` if the Redirect does not exist.

  ## Examples

      iex> get_redirect!(123)
      %Redirect{}

      iex> get_redirect!(456)
      ** (Ecto.NoResultsError)

  """
  def get_redirect!(id), do: Repo.get!(Redirect, id)

  @doc """
  Creates a redirect.

  ## Examples

      iex> create_redirect(%{field: value})
      {:ok, %Redirect{}}

      iex> create_redirect(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_redirect(attrs \\ %{}) do
    %Redirect{}
    |> Redirect.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a redirect.

  ## Examples

      iex> update_redirect(redirect, %{field: new_value})
      {:ok, %Redirect{}}

      iex> update_redirect(redirect, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_redirect(%Redirect{} = redirect, attrs) do
    redirect
    |> Redirect.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a redirect.

  ## Examples

      iex> delete_redirect(redirect)
      {:ok, %Redirect{}}

      iex> delete_redirect(redirect)
      {:error, %Ecto.Changeset{}}

  """
  def delete_redirect(%Redirect{} = redirect) do
    Repo.delete(redirect)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking redirect changes.

  ## Examples

      iex> change_redirect(redirect)
      %Ecto.Changeset{data: %Redirect{}}

  """
  def change_redirect(%Redirect{} = redirect, attrs \\ %{}) do
    Redirect.changeset(redirect, attrs)
  end
end
