defmodule KalingWeb.RedirectLive.FormComponent do
  use KalingWeb, :live_component

  alias Kaling.Redirects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage redirect records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="redirect-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:redirect_to]} type="text" label="Redirect to" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Redirect</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{redirect: redirect} = assigns, socket) do
    changeset = Redirects.change_redirect(redirect)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"redirect" => redirect_params}, socket) do
    changeset =
      socket.assigns.redirect
      |> Redirects.change_redirect(redirect_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"redirect" => redirect_params}, socket) do
    save_redirect(socket, socket.assigns.action, redirect_params)
  end

  defp save_redirect(socket, :edit, redirect_params) do
    case Redirects.update_redirect(socket.assigns.redirect, redirect_params) do
      {:ok, redirect} ->
        notify_parent({:saved, redirect})

        {:noreply,
         socket
         |> put_flash(:info, "Redirect updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_redirect(socket, :new, redirect_params) do
    case Redirects.create_redirect(redirect_params) do
      {:ok, redirect} ->
        notify_parent({:saved, redirect})

        {:noreply,
         socket
         |> put_flash(:info, "Redirect created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
