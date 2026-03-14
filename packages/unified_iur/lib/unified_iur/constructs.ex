defmodule UnifiedIUR.Constructs do
  @moduledoc """
  Namespace anchor for canonical widget, layout, layering, styling, and theming
  construct families.
  """

  alias UnifiedIUR.{Container, Widgets}

  @spec modules() :: %{container: module(), widgets: module()}
  def modules do
    %{
      widgets: Widgets,
      container: Container
    }
  end
end
