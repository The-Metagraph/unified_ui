defmodule WebUi.ServerRuntime.ViewState do
  @moduledoc """
  Phoenix-to-Elm hydration payload generation.
  """

  alias WebUi.ServerRuntime.{RenderModel, State}

  @spec to_frontend_payload(State.t()) :: map()
  def to_frontend_payload(%State{} = state) do
    %{
      runtime_id: state.runtime_id,
      screen_id: state.screen_id,
      title: state.title,
      source_kind: state.source_kind,
      boundary_mode: state.boundary_mode,
      tree: RenderModel.build(state.rendered_tree),
      local_state: %{
        focused_id: nil,
        editing_ids: [],
        flash: nil
      },
      diagnostics: state.diagnostics,
      metadata: state.metadata
    }
  end
end
