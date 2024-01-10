defmodule Kaling.RedirectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kaling.Redirects` context.
  """

  @doc """
  Generate a redirect.
  """
  def redirect_fixture(user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{redirect_to: "some redirect_to"})

    {:ok, redirect} = Kaling.Redirects.create_redirect(user, attrs)

    redirect
  end
end
