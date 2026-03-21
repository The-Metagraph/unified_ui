defmodule WebUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint for native and canonical `web_ui` screens.
  """

  alias UnifiedIUR.Element
  alias WebUi.{FrontendRuntime, ServerRuntime, Transport}

  @type validation_state :: :scaffold_ready

  @spec modules() :: [module()]
  def modules do
    [
      WebUi.ServerRuntime,
      WebUi.ServerRuntime.State,
      WebUi.ServerRuntime.ViewState,
      WebUi.FrontendRuntime,
      WebUi.FrontendRuntime.Boot,
      WebUi.FrontendRuntime.Bridge
    ]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [:native_mount, :canonical_mount, :frontend_hydration, :transport_translation]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      server_authoritative: true,
      bounded_frontend_state: true,
      shared_runtime_for_native_and_canonical: true,
      frontend_asset_root: "assets/src"
    }
  end

  @spec validation_state() :: validation_state()
  def validation_state, do: :scaffold_ready

  @spec mount_native_screen(map(), keyword()) ::
          {:ok, WebUi.ServerRuntime.State.t()} | {:error, WebUi.ServerRuntime.Error.t()}
  def mount_native_screen(screen, opts \\ []) do
    ServerRuntime.mount_native_screen(screen, opts)
  end

  @spec mount_iur_screen(Element.t(), keyword()) ::
          {:ok, WebUi.ServerRuntime.State.t()} | {:error, WebUi.ServerRuntime.Error.t()}
  def mount_iur_screen(%Element{} = element, opts \\ []) do
    ServerRuntime.mount_iur_screen(element, opts)
  end

  @spec hydrate_frontend(WebUi.ServerRuntime.State.t()) ::
          {:ok, WebUi.FrontendRuntime.Model.t()} | {:error, WebUi.FrontendRuntime.Error.t()}
  def hydrate_frontend(runtime_state) do
    runtime_state
    |> ServerRuntime.frontend_payload()
    |> FrontendRuntime.hydrate()
  end

  @spec handle_native_event(WebUi.ServerRuntime.State.t(), keyword() | map()) ::
          {:ok, WebUi.ServerRuntime.State.t()} | {:error, WebUi.ServerRuntime.Error.t()}
  def handle_native_event(runtime_state, attrs) do
    attrs =
      attrs
      |> Enum.into(%{})
      |> Map.put_new(:source_kind, runtime_state.source_kind)
      |> Map.put_new(:boundary_mode, runtime_state.boundary_mode)
      |> Map.put_new(:runtime_id, runtime_state.runtime_id)
      |> Map.put_new(:screen, runtime_state.screen_id)

    with {:ok, translation} <- Transport.from_native_event(attrs) do
      ServerRuntime.handle_event(runtime_state, translation)
    end
  end
end
