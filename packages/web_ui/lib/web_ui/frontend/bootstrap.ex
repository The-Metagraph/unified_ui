defmodule WebUi.Frontend.Bootstrap do
  @moduledoc """
  Frontend hydration helpers for the scaffolded `web_ui` runtime.
  """

  alias WebUi.Frontend.Model

  @spec hydrate(map()) :: {:ok, Model.t()} | {:error, WebUi.Frontend.Error.t()}
  def hydrate(payload) when is_map(payload) do
    Model.new(payload)
  end

  @spec boot_contract() :: map()
  def boot_contract do
    %{
      required_keys: [:screen, :widgets, :widget_summaries, :render_tree, :bridge, :revision],
      local_state_authoritative?: false
    }
  end
end
