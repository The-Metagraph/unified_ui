defmodule WebUi.Info do
  @moduledoc """
  Summary helpers for the `web_ui` package scaffold.
  """

  alias WebUi.Widget

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: WebUi.package_identity(),
      runtime_split?: WebUi.Runtime.split?(),
      module_area_names: WebUi.module_areas() |> Map.keys() |> Enum.sort(),
      assumptions: WebUi.Runtime.assumptions(),
      browser_bridge: %{
        entry_module: WebUi.Frontend.entry_module(),
        boot_contract: WebUi.Frontend.boot_contract()
      },
      widget_families: WebUi.Widgets.families(),
      validation_state: validation_state(),
      tooling: WebUi.Tooling.capabilities()
    }
  end

  @spec widget_summary(Widget.t() | map() | keyword()) :: map()
  def widget_summary(%Widget{} = widget), do: Widget.summary(widget)

  def widget_summary(widget) do
    widget
    |> WebUi.Widgets.normalize()
    |> case do
      {:ok, normalized} -> Widget.summary(normalized)
      {:error, reason} -> %{valid?: false, reason: reason}
    end
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      widgets: WebUi.Widgets.validation_state(),
      server: WebUi.Server.validation_state(),
      frontend: WebUi.Frontend.validation_state()
    }
  end
end
