defmodule UnifiedUi.Forms do
  @moduledoc """
  Package-facing reference surface for authored form composition kinds.
  """

  @spec kinds() :: [atom()]
  def kinds do
    [:form_builder, :host_form_shell, :field_group, :field, :form_field]
  end
end
