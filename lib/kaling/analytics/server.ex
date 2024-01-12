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
  Note that any data not persisted to the database will be lost if the process crashes. Configure the opts
  according to your risk tolerance and database scale.

  ## Examples

      iex> Kaling.Analytics.Server.init()
      {:ok, %{collected: [], max_collection: 1000, max_relay_time: 20, current_timer: #Reference<0.3372082085.2082082085.2082082085.2082082085>}}

  """
  @impl true
  def init(opts \\ []) do
    {:ok,
     %{
       collected: [],
       max_collection: opts[:max_collection] || 1000,
       max_relay_time: opts[:max_relay_time] || 20,
       current_timer: Process.send_after(self(), :write_db, (opts[:max_relay_time] || 20) * 1000)
     }}
  end

  @impl true
  def handle_cast({:record_event, %{conn: conn, redirect: redirect}}, state) do
    event = initialize_event(conn, redirect)
    PubSub.broadcast(Kaling.PubSub, "events:user:#{event.user_id}", {:new_event, event})
    state = %{state | collected: [event | state.collected]}

    if Enum.count(state.collected) >= state.max_collection do
      send(self(), :write_db)
    end

    {:noreply, state}
  end

  @impl true
  def handle_call({:list_events, user_id}, _from, state) do
    {:reply, Enum.filter(state.collected, &(&1.user_id == user_id)), state}
  end

  @impl true
  def handle_info(:write_db, state) do
    # handle non-timer calls by cancelling the timer, we don't care if it has expired
    Process.cancel_timer(state.current_timer, async: true, info: false)
    if Enum.count(state.collected) > 0, do: create_events(state.collected)

    {:noreply,
     %{
       state
       | collected: [],
         current_timer: Process.send_after(self(), :write_db, state.max_relay_time * 1000)
     }}
  end
end
