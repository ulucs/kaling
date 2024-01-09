defmodule Kaling.RedirectsTest do
  use Kaling.DataCase

  alias Kaling.Redirects

  describe "redirects" do
    alias Kaling.Redirects.Redirect

    import Kaling.RedirectsFixtures

    @invalid_attrs %{redirect_to: nil}

    test "list_redirects/0 returns all redirects" do
      redirect = redirect_fixture()
      assert Redirects.list_redirects() == [redirect]
    end

    test "get_redirect!/1 returns the redirect with given id" do
      redirect = redirect_fixture()
      assert Redirects.get_redirect!(redirect.id) == redirect
    end

    test "create_redirect/1 with valid data creates a redirect" do
      valid_attrs = %{redirect_to: "some redirect_to"}

      assert {:ok, %Redirect{} = redirect} = Redirects.create_redirect(valid_attrs)
      assert redirect.redirect_to == "some redirect_to"
    end

    test "create_redirect/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Redirects.create_redirect(@invalid_attrs)
    end

    test "update_redirect/2 with valid data updates the redirect" do
      redirect = redirect_fixture()
      update_attrs = %{redirect_to: "some updated redirect_to"}

      assert {:ok, %Redirect{} = redirect} = Redirects.update_redirect(redirect, update_attrs)
      assert redirect.redirect_to == "some updated redirect_to"
    end

    test "update_redirect/2 with invalid data returns error changeset" do
      redirect = redirect_fixture()
      assert {:error, %Ecto.Changeset{}} = Redirects.update_redirect(redirect, @invalid_attrs)
      assert redirect == Redirects.get_redirect!(redirect.id)
    end

    test "delete_redirect/1 deletes the redirect" do
      redirect = redirect_fixture()
      assert {:ok, %Redirect{}} = Redirects.delete_redirect(redirect)
      assert_raise Ecto.NoResultsError, fn -> Redirects.get_redirect!(redirect.id) end
    end

    test "change_redirect/1 returns a redirect changeset" do
      redirect = redirect_fixture()
      assert %Ecto.Changeset{} = Redirects.change_redirect(redirect)
    end
  end
end
