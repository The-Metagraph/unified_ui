defmodule WebUi.FrontendRuntime do
  @moduledoc """
  Elm-facing frontend runtime scaffold for `web_ui`.
  """

  alias WebUi.FrontendRuntime.{Boot, Bridge, Error, Message, Model}

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, Boot, Bridge, Message, Model, Error]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [:elm_bootstrap, :bounded_local_state, :bridge_translation]
  end

  @spec hydrate(map()) :: {:ok, Model.t()} | {:error, Error.t()}
  def hydrate(payload) when is_map(payload) do
    Boot.hydrate(payload)
  end
end
