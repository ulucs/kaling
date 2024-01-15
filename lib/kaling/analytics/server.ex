defmodule Kaling.Analytics.Server do
  @moduledoc """
  The analytics GenServer

  Responsible for collection redirection data, storing it in the database and
  providing it to the user via PubSub.
  """
  import Kaling.Analytics
  alias Phoenix.PubSub

  use GenServer

  defp max_collection, do: Application.get_env(:kaling, __MODULE__)[:max_collection] || 100
  defp max_relay_time, do: Application.get_env(:kaling, __MODULE__)[:max_relay_time] || 20

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec init() :: {:ok, %{collected: [], current_timer: reference()}}
  @doc """
  Initializes the GenServer state.

  ## Examples

      iex> Kaling.Analytics.Server.init()
      {:ok, %{collected: [], current_timer: #Reference<0.3372082085.2082082085.2082082085.2082082085>}}

  """
  @impl true
  def init(_opts \\ []) do
    {:ok,
     %{
       collected: [],
       current_timer: Process.send_after(self(), :write_db, max_relay_time() * 1000)
     }}
  end

  @impl true
  def handle_cast({:record_event, %{conn: conn, redirect: redirect}}, state) do
    event = initialize_event(conn, redirect)
    PubSub.broadcast(Kaling.PubSub, "events:user:#{event.user_id}", {:new_event, event})
    state = %{state | collected: [event | state.collected]}

    if Enum.count(state.collected) >= max_collection() do
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
         current_timer:
           Process.send_after(
             self(),
             :write_db,
             max_relay_time() * 1000
           )
     }}
  end
end
