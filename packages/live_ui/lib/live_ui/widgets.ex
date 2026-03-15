defmodule LiveUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native widget modules.
  """

  @type family :: :content | :input | :navigation | :feedback | :layout | :overlay

  @spec families() :: [family()]
  def families do
    [:content, :input, :navigation, :feedback, :layout, :overlay]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
