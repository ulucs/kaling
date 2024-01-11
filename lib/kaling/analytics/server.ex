defmodule Kaling.Analytics.Server do
  @moduledoc """
  The analytics GenServer

  Responsible for collection redirection data, storing it in the database and
  providing it to the user via PubSub.
  """
  import Kaling.Analytics
  alias Phoenix.PubSub

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Initializes the GenServer state.

  Having a larger `max_collection` value will result in more memory usage, but less database writes.
  `max_collection` has an upper limit of 65,535/3 ~ 20,000 due to postgres limits. (using COPY would alleviate
  this) Having a larger `max_relay_time` value will result in less database writes, but more memory usage.
  Note that any data not persisted to the database will be lost if the process crashes.
  Configure the opts according to your risk tolerance and database scale.

  ## Examples

      iex> Kaling.Analytics.Server.init()
      {:ok, %{collected: [], max_collection: 1000, max_relay_time: 20, last_relay: 1588617600}}

  """
  @impl true
  def init(opts \\ []) do
    schedule_write(opts[:max_relay_time] || 20)

    {:ok,
     %{
       collected: [],
       max_collection: opts[:max_collection] || 1000,
       max_relay_time: opts[:max_relay_time] || 20,
       last_relay: :os.system_time(:second)
     }}
  end

  @impl true
  def handle_cast({:record_event, %{conn: conn, redirect: redirect}}, state) do
    event = initialize_event(conn, redirect)
    PubSub.broadcast(Kaling.PubSub, "events:user:#{event.user_id}", event)

    if Enum.count(state.collected) >= state.max_collection do
      send_writes(state)
    else
      {:noreply, %{state | collected: [event | state.collected]}}
    end
  end

  @impl true
  def handle_info(:write_db, state) do
    if :os.system_time(:second) > state.last_relay + state.max_relay_time do
      send_writes(state)
    else
      schedule_write(state.max_relay_time)
      {:noreply, state}
    end
  end

  defp send_writes(state) do
    create_events(state.collected)
    schedule_write(state.max_relay_time)
    {:noreply, flush_collected(state)}
  end

  # this is probably not even necessary, checking when an event is received would probably be enough
  defp schedule_write(max_relay_time) do
    Process.send_after(self(), :write_db, max_relay_time * 1000)
  end

  defp flush_collected(state) do
    %{state | collected: [], last_relay: :os.system_time(:second)}
  end
end
