defmodule KalingWeb.EventsLive.Index do
  import Kaling.Analytics
  alias Contex.Plot
  alias Phoenix.PubSub
  use KalingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    PubSub.subscribe(Kaling.PubSub, "events:user:#{user.id}")

    recent_events =
      GenServer.call(Kaling.Analytics.Server, {:list_events, user.id})

    events = list_events(user, recent_events)
    redirect_analytics = count_events_by_redirect(user, recent_events)
    ua_analytics = count_events_by_ua(user, recent_events)

    {:ok,
     socket
     |> stream_configure(:events, dom_id: &"events-#{&1.created_at}")
     |> stream(:events, events, limit: 10, at: 0)
     |> assign(:link_analytics, redirect_analytics)
     |> assign(:link_graph, generate_analytics_graph(redirect_analytics))
     |> assign(:ua_analytics, ua_analytics)
     |> assign(:ua_graph, generate_ua_graph(ua_analytics))}
  end

  @impl true
  def handle_info({:new_event, event}, socket) do
    updated_link = update_count_events_by_redirect(socket.assigns.link_analytics, [event])
    updated_ua = update_count_events_by_ua(socket.assigns.ua_analytics, [event])

    {:noreply,
     socket
     |> stream_insert(:events, event, at: 0)
     |> assign(:link_analytics, updated_link)
     |> assign(:link_graph, generate_analytics_graph(updated_link))
     |> assign(:ua_analytics, updated_ua)
     |> assign(:ua_graph, generate_ua_graph(updated_ua))}
  end

  defp generate_analytics_graph(%{} = data), do: generate_analytics_graph(Map.to_list(data))
  defp generate_analytics_graph([]), do: no_data()

  defp generate_analytics_graph(data_list) when is_list(data_list) do
    chart = data_list |> Contex.Dataset.new() |> Contex.BarChart.new()

    Plot.new(400, 400, chart)
    |> Plot.titles("Redirect Analytics", "")
    |> Plot.axis_labels("Redirects", "Count")
    |> Plot.to_svg()
  end

  defp generate_ua_graph(%{} = data), do: generate_ua_graph(Map.to_list(data))
  defp generate_ua_graph([]), do: no_data()

  defp generate_ua_graph(data_list) when is_list(data_list) do
    chart =
      data_list
      |> Enum.map(&pick_browser/1)
      |> Contex.Dataset.new()
      |> Contex.BarChart.new()

    Plot.new(400, 400, chart)
    |> Plot.titles("User Agent Analytics", "")
    |> Plot.axis_labels("User Agents", "Count")
    |> Plot.to_svg()
  end

  defp no_data(), do: {:safe, ["<div>No data yet.</div>"]}

  defp pick_browser({ua, ct}),
    do: {
      # ofc this is not a good way to do this, I should probably pull in an external library
      ua |> String.split(~r"\s+") |> List.last(),
      ct
    }
end
