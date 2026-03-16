defmodule LiveUi.Runtime.ScreenComponent do
  @moduledoc """
  Shared LiveComponent host for mounted native and renderer-driven screens.
  """

  use Phoenix.LiveComponent

  alias LiveUi.Runtime.State
  alias UnifiedIUR.Interaction

  @impl true
  def update(%{runtime_state: %State{} = runtime_state} = assigns, socket) do
    socket =
      socket
      |> assign(Map.put(assigns, :runtime_state, runtime_state))
      |> assign_new(:last_translation, fn -> nil end)
      |> assign_new(:runtime_event_error, fn -> nil end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put_new(:last_translation, nil)
      |> Map.put_new(:runtime_event_error, nil)

    ~H"""
    <section id={@id} data-live-ui-runtime="screen">
      <%= render_screen(@runtime_state, "##{@id}") %>

      <section data-live-ui-signal-preview="true">
        <h2>Canonical Signal Preview</h2>

        <%= if @last_translation && @last_translation.signal do %>
          <p data-live-ui-signal-status="true">Signal captured from the latest interaction.</p>
          <p data-live-ui-signal-type="true"><%= @last_translation.signal.type %></p>
          <p data-live-ui-runtime-event="true"><%= @last_translation.runtime_event %></p>
          <pre data-live-ui-signal-payload="true"><%= inspect(@last_translation.signal.data, pretty: true, limit: :infinity) %></pre>
          <pre data-live-ui-signal-translation="true"><%= inspect(@last_translation, pretty: true, limit: :infinity) %></pre>
        <% else %>
          <p data-live-ui-signal-empty="true">
            No signal captured yet. Trigger the example interaction to emit and inspect its canonical signal.
          </p>
        <% end %>
      </section>

      <pre :if={@runtime_event_error} data-live-ui-runtime-event-error="true"><%= inspect(@runtime_event_error, pretty: true, limit: :infinity) %></pre>
    </section>
    """
  end

  @impl true
  def handle_event(
        "canonical_interaction",
        %{"interaction" => encoded_interaction} = params,
        socket
      ) do
    runtime_state = socket.assigns.runtime_state

    with {:ok, interaction} <- decode_interaction(encoded_interaction),
         payload = canonical_payload(params),
         {:ok, translation} <-
           LiveUi.Signals.from_interaction(
             interaction,
             screen: runtime_state.screen.id(),
             mode: runtime_state.mode,
             boundary: :boundary,
             element_id: Map.get(params, "element_id"),
             widget: Map.get(params, "widget"),
             payload: payload
           ) do
      {:noreply,
       socket
       |> assign(:last_translation, translation)
       |> assign(:runtime_event_error, nil)}
    else
      {:error, reason} ->
        {:noreply, assign(socket, :runtime_event_error, reason)}
    end
  end

  defp render_screen(runtime_state, event_target) do
    rendered_assigns =
      runtime_state.assigns
      |> Map.put(:runtime_state, runtime_state)
      |> Map.put(:event_target, event_target)
      |> Map.put_new(:id, to_string(runtime_state.screen.id()))

    runtime_state.screen.render(rendered_assigns)
  end

  defp decode_interaction(encoded_interaction) when is_binary(encoded_interaction) do
    case Base.url_decode64(encoded_interaction, padding: false) do
      {:ok, binary} ->
        try do
          {:ok, Interaction.new(:erlang.binary_to_term(binary, [:safe]))}
        rescue
          ArgumentError -> {:error, :invalid_canonical_interaction}
        end

      :error ->
        {:error, :invalid_canonical_interaction}
    end
  end

  defp decode_interaction(_other), do: {:error, :invalid_canonical_interaction}

  defp canonical_payload(params) when is_map(params) do
    params
    |> Map.drop(["interaction", "element_id", "widget", "_target"])
  end
end
