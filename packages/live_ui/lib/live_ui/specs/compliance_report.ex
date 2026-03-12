defmodule LiveUi.Specs.ComplianceReport do
  @moduledoc """
  Derived compliance report emitted by the local spec governance checker.
  """

  defstruct version: 1, generated_at: nil, subjects: []

  @type subject_result :: %{
          required(:subject_id) => String.t(),
          required(:status) => String.t(),
          optional(:governance_checks) => [map()],
          optional(:verification_checks) => [map()],
          optional(:exceptions_applied) => [String.t()],
          optional(:findings) => [map()]
        }

  @type t :: %__MODULE__{
          version: pos_integer(),
          generated_at: String.t() | nil,
          subjects: [subject_result()]
        }

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = report) do
    %{
      version: report.version,
      generated_at: report.generated_at,
      subjects: report.subjects
    }
  end
end
