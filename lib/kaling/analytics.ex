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
      created_at: DateTime.utc_now()
    }
  end

  def create_events(events) do
    Repo.insert_all(Event, events)
  end

  def list_events(user, update_events \\ []) do
    Event
    |> where([e], e.user_id == ^user.id)
    # expensive query since we're optimizing for writes
    # possible mitigation: materialized indexed view that refreshes every 5-10 minutes
    |> order_by([e], desc: e.created_at)
    |> limit(^(10 - Enum.count(update_events)))
    |> Repo.all()
    |> Enum.concat(update_events)
  end

  # these aggregate queries should exist in pairs so they can be updated with additional data
  # we have to deal with data that is possibly not persisted yet
  def count_events_by_redirect(user, update_events \\ []) do
    Event
    |> where([e], e.user_id == ^user.id)
    # don't fetch duplicate events, change this to NOT IN after we have >1 GenServers
    |> where([e], e.created_at < ^before_all_events(update_events))
    |> group_by([e], e.redirect_to)
    |> select([e], {e.redirect_to, count(e.id)})
    |> Repo.all()
    |> Map.new()
    |> update_count_events_by_redirect(update_events)
  end

  def update_count_events_by_redirect(aggregate, new_events) do
    Enum.reduce(new_events, aggregate, fn %{redirect_to: rt}, acc ->
      Map.update(acc, rt, 1, &(&1 + 1))
    end)
  end

  def count_events_by_ua(user, update_events \\ []) do
    Event
    |> where([e], e.user_id == ^user.id)
    # don't fetch duplicate events, change this to NOT IN after we have >1 GenServers
    |> where([e], e.created_at < ^before_all_events(update_events))
    |> group_by([e], e.headers["user-agent"])
    |> select([e], {e.headers["user-agent"], count(e.id)})
    |> Repo.all()
    |> Map.new()
    |> update_count_events_by_ua(update_events)
  end

  def update_count_events_by_ua(aggregate, new_events) do
    Enum.reduce(new_events, aggregate, fn %{headers: headers}, acc ->
      Map.update(acc, headers["user-agent"], 1, &(&1 + 1))
    end)
  end

  defp before_all_events(update_events) do
    if Enum.count(update_events) > 0 do
      Enum.at(update_events, -1).created_at
    else
      DateTime.utc_now(:second)
    end
  end
end
