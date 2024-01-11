defmodule KalingWeb.EventsLive.Index do
  alias Phoenix.PubSub
  use KalingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(Kaling.PubSub, "events:user:#{socket.assigns.current_user.id}")

    recent_events =
      GenServer.call(Kaling.Analytics.Server, {:list_events, socket.assigns.current_user.id})

    {:ok, stream(socket, :events, recent_events, dom_id: &"events-#{&1.created_at}")}
  end

  @impl true
  def handle_info({:new_event, event}, socket) do
    {:noreply, stream_insert(socket, :events, event, at: 0)}
  end
end
