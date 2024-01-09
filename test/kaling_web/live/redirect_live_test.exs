defmodule KalingWeb.RedirectLiveTest do
  use KalingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Kaling.RedirectsFixtures

  @create_attrs %{redirect_to: "some redirect_to"}
  @update_attrs %{redirect_to: "some updated redirect_to"}
  @invalid_attrs %{redirect_to: nil}

  defp create_redirect(_) do
    redirect = redirect_fixture()
    %{redirect: redirect}
  end

  describe "Index" do
    setup [:create_redirect]

    test "lists all redirects", %{conn: conn, redirect: redirect} do
      {:ok, _index_live, html} = live(conn, ~p"/redirects")

      assert html =~ "Listing Redirects"
      assert html =~ redirect.redirect_to
    end

    test "saves new redirect", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/redirects")

      assert index_live |> element("a", "New Redirect") |> render_click() =~
               "New Redirect"

      assert_patch(index_live, ~p"/redirects/new")

      assert index_live
             |> form("#redirect-form", redirect: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#redirect-form", redirect: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/redirects")

      html = render(index_live)
      assert html =~ "Redirect created successfully"
      assert html =~ "some redirect_to"
    end

    test "updates redirect in listing", %{conn: conn, redirect: redirect} do
      {:ok, index_live, _html} = live(conn, ~p"/redirects")

      assert index_live |> element("#redirects-#{redirect.id} a", "Edit") |> render_click() =~
               "Edit Redirect"

      assert_patch(index_live, ~p"/redirects/#{redirect}/edit")

      assert index_live
             |> form("#redirect-form", redirect: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#redirect-form", redirect: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/redirects")

      html = render(index_live)
      assert html =~ "Redirect updated successfully"
      assert html =~ "some updated redirect_to"
    end

    test "deletes redirect in listing", %{conn: conn, redirect: redirect} do
      {:ok, index_live, _html} = live(conn, ~p"/redirects")

      assert index_live |> element("#redirects-#{redirect.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#redirects-#{redirect.id}")
    end
  end

  describe "Show" do
    setup [:create_redirect]

    test "displays redirect", %{conn: conn, redirect: redirect} do
      {:ok, _show_live, html} = live(conn, ~p"/redirects/#{redirect}")

      assert html =~ "Show Redirect"
      assert html =~ redirect.redirect_to
    end

    test "updates redirect within modal", %{conn: conn, redirect: redirect} do
      {:ok, show_live, _html} = live(conn, ~p"/redirects/#{redirect}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Redirect"

      assert_patch(show_live, ~p"/redirects/#{redirect}/show/edit")

      assert show_live
             |> form("#redirect-form", redirect: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#redirect-form", redirect: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/redirects/#{redirect}")

      html = render(show_live)
      assert html =~ "Redirect updated successfully"
      assert html =~ "some updated redirect_to"
    end
  end
end
