defmodule WebUi.FrontendRuntime.Model do
  @moduledoc """
  Bounded browser-side runtime model for `web_ui`.
  """

  @type tree :: map()
  @type t :: %__MODULE__{
          runtime_id: String.t(),
          title: String.t(),
          source_kind: :native | :canonical,
          boundary_mode: :native_local | :canonical_boundary,
          tree: tree(),
          local_state: map(),
          diagnostics: [map()],
          metadata: map()
        }

  defstruct runtime_id: "",
            title: "",
            source_kind: :native,
            boundary_mode: :native_local,
            tree: %{},
            local_state: %{focused_id: nil, flash: nil},
            diagnostics: [],
            metadata: %{}
end
