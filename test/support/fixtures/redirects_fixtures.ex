defmodule Kaling.RedirectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kaling.Redirects` context.
  """

  @doc """
  Generate a redirect.
  """
  def redirect_fixture(attrs \\ %{}) do
    {:ok, redirect} =
      attrs
      |> Enum.into(%{
        redirect_to: "some redirect_to"
      })
      |> Kaling.Redirects.create_redirect()

    redirect
  end
end
