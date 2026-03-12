defmodule UnifiedUiObservability.Extension do
  @moduledoc """
  Example extension demonstrating a custom widget and custom terminal renderer.
  """

  alias __MODULE__.Renderers
  alias __MODULE__.Widgets

  @doc """
  Returns the extension modules exposed by this example.
  """
  @spec components() :: %{widget: module(), renderer: module()}
  def components do
    %{widget: Widgets.MetricBadge, renderer: Renderers.Terminal}
  end

  defmodule Widgets.MetricBadge do
    @moduledoc """
    Example custom widget for displaying a named metric value.
    """

    defstruct [:id, :name, :value, :style, visible: true]

    @type t :: %__MODULE__{
            id: atom() | nil,
            name: String.t() | nil,
            value: term(),
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  if not Protocol.consolidated?(UnifiedIUR.Element) do
    defimpl UnifiedIUR.Element, for: UnifiedUiObservability.Extension.Widgets.MetricBadge do
      @doc false
      def children(_widget), do: []

      @doc false
      def metadata(widget) do
        %{
          type: :metric_badge,
          id: widget.id,
          name: widget.name,
          value: widget.value,
          visible: widget.visible,
          style: widget.style
        }
      end
    end
  end

  defmodule Renderers.Terminal do
    @moduledoc """
    Example custom renderer that handles `MetricBadge` before delegating
    built-in types to the default terminal renderer.
    """

    @behaviour UnifiedUi.Renderer

    alias UnifiedIUR.Layouts
    alias UnifiedIUR.Widgets
    alias UnifiedUi.Adapters.State
    alias UnifiedUi.Adapters.Terminal, as: BaseTerminal
    alias UnifiedUiObservability.Extension.Widgets.MetricBadge

    @impl true
    def render(iur_tree, opts \\ []) do
      renderer_state = State.new(:terminal, config: opts)
      root = convert_iur(iur_tree)

      {:ok,
       renderer_state
       |> State.put_root(root)
       |> State.put_metadata(:last_iur, iur_tree)}
    end

    @impl true
    def update(iur_tree, renderer_state, _opts \\ []) do
      if State.get_metadata(renderer_state, :last_iur) == iur_tree do
        {:ok, renderer_state}
      else
        {:ok,
         renderer_state
         |> State.put_root(convert_iur(iur_tree))
         |> State.put_metadata(:last_iur, iur_tree)
         |> State.bump_version()}
      end
    end

    @impl true
    def destroy(_renderer_state), do: :ok

    defp convert_iur(%MetricBadge{name: name, value: value}) do
      %Widgets.Text{content: "#{name}: #{inspect(value)}"}
    end

    defp convert_iur(%Layouts.VBox{} = vbox) do
      %{vbox | children: Enum.map(vbox.children, &convert_iur/1)}
    end

    defp convert_iur(%Layouts.HBox{} = hbox) do
      %{hbox | children: Enum.map(hbox.children, &convert_iur/1)}
    end

    defp convert_iur(other) do
      other
      |> BaseTerminal.convert_iur()
    end
  end
end
