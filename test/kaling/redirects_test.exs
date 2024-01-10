defmodule Kaling.RedirectsTest do
  use Kaling.DataCase

  alias Kaling.Redirects

  describe "redirects" do
    alias Kaling.Redirects.Redirect

    import Kaling.RedirectsFixtures
    import Kaling.AccountsFixtures

    @invalid_attrs %{redirect_to: nil}

    test "list_redirects/1 returns all redirects of user" do
      user = user_fixture()
      redirect = redirect_fixture(user)

      assert [Redirects.resolve_redirect(redirect)] == Redirects.list_redirects(user)
    end

    test "list_redirects/1 returns empty list if user has no redirects" do
      user = user_fixture()

      assert [] == Redirects.list_redirects(user)
    end

    test "list_redirects/1 does not return redirects of other users" do
      user = user_fixture()
      other_user = user_fixture()
      _redirect = redirect_fixture(other_user)

      assert [] == Redirects.list_redirects(user)
    end

    test "get_redirect!/2 returns the redirect with given id" do
      user = user_fixture()
      redirect = redirect_fixture(user)

      assert Redirects.get_redirect!(redirect.id, user) == Redirects.resolve_redirect(redirect)
    end

    test "get_redirect!/2 raises Ecto.NoResultsError if redirect does not exist" do
      user = user_fixture()

      assert_raise Ecto.NoResultsError, fn -> Redirects.get_redirect!(123, user) end
    end

    test "get_redirect!/2 raises Ecto.NoResultsError if redirect belongs to other user" do
      user = user_fixture()
      other_user = user_fixture()
      redirect = redirect_fixture(other_user)

      assert_raise Ecto.NoResultsError, fn -> Redirects.get_redirect!(redirect.id, user) end
    end

    test "create_redirect/2 with valid data creates a redirect belonging to the user" do
      user = user_fixture()
      valid_attrs = %{redirect_to: "some redirect_to"}

      assert {:ok, %Redirect{} = redirect} = Redirects.create_redirect(user, valid_attrs)
      assert redirect.redirect_to == "some redirect_to"
      assert redirect.user_id == user.id
    end

    test "create_redirect/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Redirects.create_redirect(user, @invalid_attrs)
    end

    test "update_redirect/3 with valid data updates the redirect" do
      user = user_fixture()
      redirect = redirect_fixture(user)
      update_attrs = %{redirect_to: "some updated redirect_to"}

      assert {:ok, %Redirect{} = redirect} =
               Redirects.update_redirect(redirect, user, update_attrs)

      assert redirect.redirect_to == "some updated redirect_to"
    end

    test "update_redirect/3 with invalid data returns error changeset" do
      user = user_fixture()
      redirect = redirect_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Redirects.update_redirect(redirect, user, @invalid_attrs)

      assert Redirects.resolve_redirect(redirect) == Redirects.get_redirect!(redirect.id, user)
    end

    test "update_redirect/3 returns error if redirect belongs to another user" do
      user = user_fixture()
      other_user = user_fixture()
      redirect = redirect_fixture(other_user)

      assert {:error, _} =
               Redirects.update_redirect(redirect, user, %{
                 redirect_to: "some updated redirect_to"
               })
    end

    test "delete_redirect/1 deletes the redirect if it belongs to the user" do
      user = user_fixture()
      redirect = redirect_fixture(user)
      assert {:ok, %Redirect{}} = Redirects.delete_redirect(redirect, user)
      assert_raise Ecto.NoResultsError, fn -> Redirects.get_redirect!(redirect.id, user) end
    end

    test "delete_redirect/1 returns error if redirect belongs to another user" do
      user = user_fixture()
      other_user = user_fixture()
      redirect = redirect_fixture(other_user)

      assert {:error, _} = Redirects.delete_redirect(redirect, user)
    end

    test "change_redirect/2 returns a redirect changeset" do
      user = user_fixture()
      redirect = redirect_fixture(user)

      assert %Ecto.Changeset{} = Redirects.change_redirect(redirect, user)
    end
  end
end
