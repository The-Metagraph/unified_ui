defmodule TerminalUi.Widgets do
  @moduledoc """
  Native widget namespace placeholder for `terminal_ui`.
  """

  @type family :: :content | :layout | :input | :navigation | :feedback

  @spec families() :: [family()]
  def families do
    [:content, :layout, :input, :navigation, :feedback]
  end
end
