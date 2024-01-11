defmodule Kaling.Analytics do
  alias Kaling.Repo
  alias Kaling.Analytics.Event
  alias Kaling.Redirects.Redirect
  alias Plug.Conn

  import Ecto.Query

  defp parse_ip(ip) do
    case ip do
      {a, b, c, d} -> "#{a}.#{b}.#{c}.#{d}"
      {a, b, c, d, e, f, g, h} -> "#{a}::#{b}::#{c}::#{d}::#{e}::#{f}::#{g}::#{h}"
      _ -> ip |> Tuple.to_list() |> Enum.map(&Integer.to_string/1) |> Enum.join("-")
    end
  end

  def initialize_event(%Conn{} = conn, %Redirect{} = redirect) do
    %{
      ip: parse_ip(conn.remote_ip),
      headers: Map.new(conn.req_headers),
      cookies: Map.new(conn.cookies),
      user_id: redirect.user_id,
      redirected_from: redirect.short_url,
      redirect_to: redirect.redirect_to,
      created_at: DateTime.utc_now(:second)
    }
  end

  def create_events(events) do
    Repo.insert_all(Event, events)
  end

  def list_events(user) do
    Event
    |> where([e], e.user_id == ^user.id)
    # expensive query since we're optimizing for writes
    # possible mitigation: materialized indexed view that refreshes every 5-10 minutes
    |> order_by([e], desc: e.created_at)
    |> limit(10)
    |> Repo.all()
  end
end
