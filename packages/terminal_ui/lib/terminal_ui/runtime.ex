defmodule TerminalUi.Runtime do
  @moduledoc """
  Shared runtime entrypoint for native and canonical `terminal_ui` screens.
  """

  alias TerminalUi.Backend
  alias TerminalUi.Renderer
  alias TerminalUi.Runtime.{Boot, Error, EventLoop, Realization, Screen, State}
  alias UnifiedIUR.Element

  @type validation_state :: :foundational_realization_ready

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      Boot,
      EventLoop,
      Screen,
      Realization,
      State,
      Error
    ]
  end

  @spec capabilities() :: [atom()]
  def capabilities do
    [
      :native_mount,
      :runtime_boot,
      :capability_snapshot,
      :backend_selection,
      :event_loop_scaffold,
      :screen_composition,
      :shared_realization_model,
      :focus_traversal,
      :binding_surface,
      :deterministic_runtime_errors
    ]
  end

  @spec validation_state() :: validation_state()
  def validation_state, do: :foundational_realization_ready

  @spec assumptions() :: map()
  def assumptions do
    %{
      term_ui_backed: true,
      shared_runtime_for_native_and_canonical: true,
      capability_aware: true,
      keyboard_first: true,
      renderer_boot_path_present: true
    }
  end

  @spec mount_native_screen(map(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_native_screen(screen, opts \\ []) when is_map(screen) do
    with {:ok, backend_mode} <- Backend.select(opts) do
      Boot.prepare_native_screen(screen, backend_mode, opts)
    else
      {:error, {:unsupported_backend_mode, mode}} ->
        {:error, Error.new(:unsupported_backend_mode, %{backend_mode: mode})}
    end
  end

  @spec mount_iur_screen(Element.t(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_iur_screen(%Element{} = element, opts \\ []) do
    with {:ok, _backend_mode} <- Backend.select(opts),
         {:ok, rendered_root} <- Renderer.render(element, opts) do
      Boot.prepare_rendered_screen(rendered_root, :canonical, opts)
    else
      {:error, {:unsupported_backend_mode, mode}} ->
        {:error, Error.new(:unsupported_backend_mode, %{backend_mode: mode})}

      {:error, %TerminalUi.Renderer.Error{} = error} ->
        {:error, Error.new(error.reason, error.details)}
    end
  end
end
