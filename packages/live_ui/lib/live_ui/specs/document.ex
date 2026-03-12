defmodule LiveUi.Specs.Document do
  @moduledoc """
  Parsed Spec Led document used by the local governance/compliance checker.
  """

  @enforce_keys [:path, :meta]
  defstruct [
    :path,
    :meta,
    :governance,
    requirements: [],
    scenarios: [],
    verification: [],
    exceptions: []
  ]

  @type json_map :: %{optional(String.t()) => term()}

  @type t :: %__MODULE__{
          path: String.t(),
          meta: json_map(),
          governance: json_map() | nil,
          requirements: [json_map()],
          scenarios: [json_map()],
          verification: [json_map()],
          exceptions: [json_map()]
        }
end
