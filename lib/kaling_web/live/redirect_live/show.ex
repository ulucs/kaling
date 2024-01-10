defmodule KalingWeb.RedirectLive.Show do
  use KalingWeb, :live_view

  alias Kaling.Redirects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:redirect, Redirects.get_redirect!(id, socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Redirect"
  defp page_title(:edit), do: "Edit Redirect"
end
