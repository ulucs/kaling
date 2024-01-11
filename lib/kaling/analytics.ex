defmodule Kaling.Analytics do
  alias Kaling.Repo
  alias Kaling.Analytics.Event
  alias Kaling.Redirects.Redirect
  alias Plug.Conn

  def initialize_event(%Conn{} = conn, %Redirect{} = redirect) do
    %Event{
      ip: conn.remote_ip,
      headers: conn.req_headers,
      cookies: conn.cookies,
      user_id: redirect.user_id,
      redirected_from: redirect.short_url,
      redirect_to: redirect.redirect_to
    }
  end

  def create_events(events) do
    Repo.insert_all(Event, events)
  end
end
