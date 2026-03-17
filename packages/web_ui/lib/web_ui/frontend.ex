defmodule WebUi.Frontend do
  @moduledoc """
  Package-facing entrypoint for the Elm frontend runtime boundary.
  """

  alias WebUi.Frontend.{Bootstrap, Bridge, Model, Realization}

  @type responsibility ::
          :elm_rendering
          | :bounded_local_state
          | :browser_bridge
          | :frontend_bootstrap

  @type capability ::
          :hydrate
          | :render_realization
          | :local_state_updates
          | :outbound_messages
          | :sync_ingestion
          | :browser_bridge

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :elm_rendering,
      :bounded_local_state,
      :browser_bridge,
      :frontend_bootstrap
    ]
  end

  @spec capabilities() :: [capability()]
  def capabilities do
    [
      :hydrate,
      :render_realization,
      :local_state_updates,
      :outbound_messages,
      :sync_ingestion,
      :browser_bridge
    ]
  end

  @spec assets_root() :: String.t()
  def assets_root do
    Path.expand("../assets/elm", __DIR__)
  end

  @spec entry_module() :: String.t()
  def entry_module do
    "WebUi.Main"
  end

  @spec hydrate(map()) :: {:ok, Model.t()} | {:error, WebUi.Frontend.Error.t()}
  def hydrate(payload) do
    Bootstrap.hydrate(payload)
  end

  @spec ingest_sync(map()) :: {:ok, Model.t()} | {:error, term()}
  def ingest_sync(envelope) do
    Bridge.ingest_sync(envelope)
  end

  @spec put_local(Model.t(), atom(), term()) ::
          {:ok, Model.t()} | {:error, WebUi.Frontend.Error.t()}
  def put_local(%Model{} = model, key, value) do
    Model.put_local(model, key, value)
  end

  @spec realize([map()], map()) :: [map()]
  def realize(render_tree, local_state \\ %{}) do
    Realization.realize(render_tree, local_state)
  end

  @spec outbound_message(Model.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, WebUi.Frontend.Error.t()}
  def outbound_message(%Model{} = model, event, payload, opts \\ []) do
    Bridge.outbound(model, event, payload, opts)
  end

  @spec modules() :: [module()]
  def modules do
    [Bootstrap, Bridge, Model, Realization]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      bounded_local_state?: true,
      canonical_meaning_owned_by_server?: true,
      shared_runtime_for_native_and_iur?: true
    }
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      hydration: :ready,
      foundational_realization: :ready,
      browser_bridge: :ready,
      local_state: :ready,
      outbound_messages: :ready
    }
  end

  @spec boot_contract() :: map()
  def boot_contract do
    Bootstrap.boot_contract()
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
