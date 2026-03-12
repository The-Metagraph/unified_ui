defmodule LiveUi.Live.Engine do
  @moduledoc """
  Shared runtime engine used by `LiveUi.Screen` wrappers and `DynamicLive`.
  """

  use Phoenix.Component

  alias LiveUi
  alias LiveUi.ConfigurationError
  alias LiveUi.Runtime
  alias LiveUi.Runtime.Model
  alias LiveUi.Source
  alias LiveUi.Session
  alias Phoenix.LiveView.Socket

  @spec mount(map(), map(), Socket.t(), module()) :: {:ok, Socket.t()}
  def mount(params, session, %Socket{} = socket, wrapper_module)
      when is_map(params) and is_map(session) and is_atom(wrapper_module) do
    source_module = wrapper_module.__live_ui_screen__().source
    extra_context = normalize_context(wrapper_module.liveui_context(params, session, socket))
    runtime_context = Session.normalize(params, session, socket, extra_context)

    source_opts =
      normalize_source_opts(wrapper_module.liveui_source_opts(params, session, socket))

    case Runtime.init(
           source: source_module,
           source_opts: source_opts,
           runtime_context: runtime_context
         ) do
      {:ok, model} ->
        {:ok, assign_model(socket, model)}

      {:error, error} ->
        {:ok, assign_error(socket, error, source_module)}
    end
  end

  @spec mount_dynamic(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount_dynamic(params, session, %Socket{} = socket)
      when is_map(params) and is_map(session) do
    with {:ok, config} <- LiveUi.fetch_dynamic_session(session),
         {:ok, runtime_source_opts} <- fetch_runtime_source_opts(config),
         extra_context <- normalize_context(fetch_map_value(config, "context", %{})),
         runtime_context <- Session.normalize(params, session, socket, extra_context),
         {:ok, model} <- Runtime.init(runtime_source_opts ++ [runtime_context: runtime_context]) do
      {:ok, assign_model(socket, model)}
    else
      {:error, error} ->
        {:ok, assign_error(socket, error, nil)}
    end
  rescue
    error in ConfigurationError -> {:ok, assign_error(socket, error, nil)}
  end

  @spec handle_event(String.t(), map(), Socket.t(), module()) :: {:noreply, Socket.t()}
  def handle_event(event_name, payload, %Socket{} = socket, _wrapper_module)
      when is_binary(event_name) and is_map(payload) do
    case socket.assigns[:live_ui_model] do
      %Model{} = model ->
        case Runtime.handle_event(model, event_name, payload) do
          {:ok, updated_model} ->
            {:noreply, assign_model(socket, updated_model)}

          {:error, error} ->
            {:noreply, assign_error(socket, error, model.source)}
        end

      _other ->
        {:noreply,
         assign_error(socket, ConfigurationError.new("live_ui engine is not initialized"), nil)}
    end
  end

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:live_ui_error, fn -> nil end)
      |> assign_new(:live_ui_model, fn -> nil end)

    ~H"""
    <section
      id="live-ui-shell"
      class="live-ui-shell"
      data-live-ui-status={shell_status(@live_ui_model, @live_ui_error)}
    >
      <%= if @live_ui_error do %>
        <div class="live-ui-shell__error" role="alert">
          <h2>live_ui configuration error</h2>
          <p><%= Exception.message(@live_ui_error) %></p>
        </div>
      <% else %>
        <div :if={@live_ui_model} class="live-ui-shell__ready">
          <header class="live-ui-shell__header">
            <h1><%= source_name(@live_ui_model.source) %></h1>
            <p>Status: <%= Atom.to_string(@live_ui_model.status) %></p>
          </header>

          <div class="live-ui-shell__body">
            <LiveUi.WidgetRegistry.render descriptor={@live_ui_model.descriptor_tree} />
          </div>
        </div>
      <% end %>
    </section>
    """
  end

  defp assign_model(%Socket{} = socket, %Model{} = model) do
    socket
    |> Phoenix.Component.assign(:live_ui_error, nil)
    |> Phoenix.Component.assign(:live_ui_model, model)
    |> Phoenix.Component.assign(:page_title, source_name(model.source))
  end

  defp assign_error(%Socket{} = socket, error, source) do
    socket
    |> Phoenix.Component.assign(:live_ui_error, error)
    |> Phoenix.Component.assign(:live_ui_model, nil)
    |> Phoenix.Component.assign(:page_title, source_name(source))
  end

  defp shell_status(%Model{} = model, nil), do: Atom.to_string(model.status)
  defp shell_status(_model, _error), do: "error"

  defp source_name(nil), do: "LiveUi"
  defp source_name(%Source{} = source), do: Source.label(source)

  defp source_name(source_module) when is_atom(source_module),
    do: Source.label(%Source{kind: :module, module: source_module})

  defp normalize_context(context) when is_map(context), do: context

  defp normalize_context(other),
    do:
      raise(
        ConfigurationError.new("liveui_context/3 must return a map", %{return: inspect(other)})
      )

  defp normalize_source_opts(opts) when is_list(opts) do
    if Keyword.keyword?(opts) do
      opts
    else
      raise ConfigurationError.new("liveui_source_opts/3 must return a keyword list", %{
              return: inspect(opts)
            })
    end
  end

  defp normalize_source_opts(other) do
    raise ConfigurationError.new("liveui_source_opts/3 must return a keyword list", %{
            return: inspect(other)
          })
  end

  defp fetch_runtime_source_opts(config) when is_map(config) do
    has_source? = has_map_value?(config, "source")
    has_iur? = has_map_value?(config, "iur")

    cond do
      has_source? and has_iur? ->
        {:error,
         ConfigurationError.new("dynamic live_ui config accepts either source or iur, not both")}

      has_source? ->
        fetch_dynamic_source(config)

      has_iur? ->
        {:ok, [iur: fetch_map_value(config, "iur")]}

      true ->
        {:error, ConfigurationError.new("dynamic live_ui config requires either source or iur")}
    end
  end

  defp fetch_dynamic_source(config) when is_map(config) do
    case fetch_map_value(config, "source") do
      source_module when is_atom(source_module) ->
        {:ok,
         [
           source: source_module,
           source_opts: normalize_source_opts(fetch_map_value(config, "source_opts", []))
         ]}

      other ->
        {:error,
         ConfigurationError.new("dynamic live_ui source must be a module", %{
           source: inspect(other)
         })}
    end
  end

  defp fetch_map_value(map, "source", default),
    do: Map.get(map, "source", Map.get(map, :source, default))

  defp fetch_map_value(map, "source_opts", default),
    do: Map.get(map, "source_opts", Map.get(map, :source_opts, default))

  defp fetch_map_value(map, "context", default),
    do: Map.get(map, "context", Map.get(map, :context, default))

  defp fetch_map_value(map, "iur", default),
    do: Map.get(map, "iur", Map.get(map, :iur, default))

  defp fetch_map_value(_map, _key, default), do: default

  defp fetch_map_value(map, key) do
    fetch_map_value(map, key, nil)
  end

  defp has_map_value?(map, key) do
    Map.has_key?(map, key) or Map.has_key?(map, String.to_atom(key))
  end
end
