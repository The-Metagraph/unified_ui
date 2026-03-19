defmodule WebUi.Widgets do
  @moduledoc """
  Native widget modules for direct use in web_ui applications.

  This area provides widgets that are specifically designed for the
  Phoenix + Elm runtime, leveraging both server-side rendering and
  client-side Elm interactivity.

  ## Submodules

  * `Native.Widget` - Base behavior for native widgets
  * `Native.Registry` - Widget registration and lookup
  * `Native.Composition` - Widget composition helpers

  ## Native Widget Contract

  All native widgets must implement the `WebUi.Widgets.Native.Widget` behavior:

  ```elixir
  defmodule MyWidget do
    use WebUi.Widgets.Native.Widget

    def id, do: :my_widget
    def metadata, do: %{name: "My Widget", family: :content, version: "1.0.0"}
    def props_schema, do: %{value: {:string, required: true}}
    def render_server(props, opts), do: ...
    def render_frontend(props, opts), do: ...
    def default_state, do: %{}
  end
  ```
  """

  alias WebUi.Widgets.Native.{Widget, Registry, Composition}

  @type widget_id :: Widget.widget_id()
  @type widget_module :: Widget.widget_module()
  @type props :: Widget.props()
  @type state :: Widget.state()
  @type t :: Widget.t()

  @doc """
  Delegates to `Registry.register/1`.
  """
  defdelegate register_widget(module), to: Registry, as: :register

  @doc """
  Delegates to `Registry.lookup/1`.
  """
  defdelegate lookup_widget(id), to: Registry, as: :lookup

  @doc """
  Delegates to `Registry.all/0`.
  """
  defdelegate list_widgets, to: Registry, as: :all

  @doc """
  Delegates to `Registry.by_family/1`.
  """
  defdelegate widgets_by_family(family), to: Registry, as: :by_family

  @doc """
  Delegates to `Widget.create/2`.
  """
  defdelegate create_widget(module, props, opts \\ []), to: Widget, as: :create

  @doc """
  Delegates to `Composition.slot/2`.
  """
  defdelegate slot(name, content \\ []), to: Composition, as: :slot

  @doc """
  Delegates to `Composition.screen/2`.
  """
  defdelegate screen(root, slots \\ %{}), to: Composition, as: :screen
end
