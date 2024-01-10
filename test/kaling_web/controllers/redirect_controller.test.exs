defmodule KalingWeb.RedirectHtmlTest do
  use KalingWeb.ConnCase

  import Kaling.RedirectsFixtures
  import Kaling.AccountsFixtures

  test "GET /r/:hash", %{conn: conn} do
    user = user_fixture()

    redirect =
      redirect_fixture(user, %{
        redirect_to: "https://www.example.com"
      })

    conn = get(conn, ~p"/r/#{redirect.hash}")
    assert html_response(conn, 302) =~ "https://www.example.com"
  end
end
