defmodule KalingWeb.RedirectHtml do
  use KalingWeb, :controller
  import Kaling.Redirects

  def get(conn, %{"hash" => hash}) do
    redirect = get_hashed_redirect!(hash)
    GenServer.cast(Kaling.Analytics.Server, {:record_event, %{conn: conn, redirect: redirect}})

    redirect(conn, external: redirect.redirect_to)
  end
end
