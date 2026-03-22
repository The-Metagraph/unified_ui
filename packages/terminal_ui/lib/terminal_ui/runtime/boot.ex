defmodule TerminalUi.Runtime.Boot do
  @moduledoc """
  Runtime boot helpers for the `terminal_ui` Phase 1 scaffold.
  """

  alias TerminalUi.{Backend, Capabilities}
  alias TerminalUi.Runtime.{Error, EventLoop, Realization, Screen, State}
  alias TerminalUi.Widget

  @required_screen_keys [:id, :title, :root]

  @spec prepare_native_screen(map(), atom(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def prepare_native_screen(screen, backend_mode, opts \\ []) do
    with :ok <- validate_screen(screen) do
      build_state(screen, backend_mode, :native, opts)
    end
  end

  @spec prepare_rendered_screen(map(), State.source_kind(), keyword()) ::
          {:ok, State.t()} | {:error, Error.t()}
  def prepare_rendered_screen(rendered_root, source_kind, opts \\ [])
      when is_map(rendered_root) do
    backend_mode = Keyword.get(opts, :backend_mode, :raw)

    screen = %{
      id: Keyword.get(opts, :screen_id, "canonical-screen"),
      title: Keyword.get(opts, :title, "Canonical Screen"),
      root: rendered_root
    }

    build_state(screen, backend_mode, source_kind, opts)
  end

  defp build_state(screen, backend_mode, source_kind, opts) do
    with {:ok, root} <- normalize_root(Map.fetch!(screen, :root)),
         screen_model <- Screen.new(Map.put(screen, :root, root), source_kind, backend_mode, opts),
         {:ok, realization} <-
           Realization.realize_screen(screen_model, backend_mode: backend_mode) do
      screen_id = to_string(Map.fetch!(screen, :id))

      {:ok,
       %State{
         runtime_id: Keyword.get(opts, :runtime_id, "terminal-ui:#{screen_id}"),
         screen_id: screen_id,
         title: Map.get(screen, :title),
         source_kind: source_kind,
         backend_mode: backend_mode,
         capabilities: Capabilities.snapshot(backend_mode: backend_mode),
         root: root,
         screen: screen_model,
         realization: realization,
         focus: Realization.focus_state(realization),
         backend_adapter: Backend.adapter_summary(backend_mode),
         event_loop: EventLoop.scaffold(backend_mode: backend_mode, screen_id: screen_id),
         lifecycle: %{
           boot: :initialized,
           terminal: :not_yet_attached,
           shutdown: :idle
         },
         validation_state: runtime_validation_state(realization)
       }}
    end
  end

  defp validate_screen(screen) when is_map(screen) do
    missing_keys =
      Enum.reject(@required_screen_keys, fn key ->
        value = Map.get(screen, key)
        not is_nil(value)
      end)

    cond do
      missing_keys != [] ->
        {:error, Error.new(:invalid_screen, %{missing_keys: missing_keys})}

      not valid_root?(Map.get(screen, :root)) ->
        {:error, Error.new(:invalid_screen_root, %{root: Map.get(screen, :root)})}

      true ->
        :ok
    end
  end

  defp valid_root?(%{kind: _kind}), do: true
  defp valid_root?(%{id: _id}), do: true
  defp valid_root?(_root), do: false

  defp normalize_root(%Widget{} = root), do: {:ok, root}

  defp normalize_root(%{kind: kind} = root) when is_atom(kind) do
    promoted_attributes =
      root
      |> Map.take([
        :content,
        :label,
        :value,
        :placeholder,
        :items,
        :orientation,
        :gap,
        :target,
        :src,
        :alt,
        :fallback_text,
        :prompt,
        :submit_key
      ])

    attrs =
      root
      |> Map.drop(Map.keys(promoted_attributes) ++ [:kind])
      |> Map.put(:attributes, Map.merge(promoted_attributes, Map.get(root, :attributes, %{})))
      |> Map.put_new(:metadata, %{
        label: root |> Map.get(:id, kind) |> to_string(),
        native_surface: true
      })

    {:ok, Widget.new(kind, attrs)}
  end

  defp runtime_validation_state(%{validation_state: :advanced_ready}),
    do: :advanced_runtime_ready

  defp runtime_validation_state(_realization), do: :foundational_realization_ready
end
