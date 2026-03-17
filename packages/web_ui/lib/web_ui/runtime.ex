defmodule WebUi.Runtime do
  @moduledoc """
  Package-facing summary of the split `web_ui` runtime model.
  """

  @spec modules() :: [module()]
  def modules do
    WebUi.Server.modules() ++ WebUi.Frontend.modules()
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      server: WebUi.Server.validation_state(),
      frontend: WebUi.Frontend.validation_state()
    }
  end

  @spec split?() :: true
  def split?, do: true

  @spec sides() :: %{server: module(), frontend: module()}
  def sides do
    %{
      server: WebUi.Server,
      frontend: WebUi.Frontend
    }
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      authoritative_server?: true,
      bounded_frontend_state?: true,
      shared_runtime_for_native_and_iur?: true
    }
  end
end
