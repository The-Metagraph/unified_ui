defmodule WebUi.Renderer.Error do
  @moduledoc """
  Structured errors for canonical `UnifiedIUR` rendering into `web_ui`.
  """

  alias UnifiedIUR.Validate.Error, as: ValidateError

  @enforce_keys [:code, :message]
  defstruct [:code, :message, details: %{}]

  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          details: map()
        }

  @spec new(atom(), String.t(), map()) :: t()
  def new(code, message, details \\ %{}) do
    %__MODULE__{code: code, message: message, details: Map.new(details)}
  end

  @spec invalid_input([ValidateError.t()]) :: t()
  def invalid_input(errors) do
    new(
      :invalid_canonical_input,
      "renderer input must be a valid canonical UnifiedIUR element",
      %{
        errors: Enum.map(errors, &ValidateError.format/1)
      }
    )
  end

  @spec missing_identity(UnifiedIUR.Element.t()) :: t()
  def missing_identity(element) do
    new(:missing_identity, "canonical elements need stable ids for Phase 2 rendering", %{
      type: element.type,
      kind: element.kind
    })
  end

  @spec unsupported_kind(UnifiedIUR.Element.t(), [atom()]) :: t()
  def unsupported_kind(element, supported_kinds) do
    new(:unsupported_kind, "canonical kind is not supported by the Phase 2 renderer", %{
      id: element.id,
      type: element.type,
      kind: element.kind,
      supported_kinds: supported_kinds
    })
  end

  @spec invalid_field(UnifiedIUR.Element.t(), atom()) :: t()
  def invalid_field(element, missing_slot) do
    new(:invalid_field_shape, "canonical field elements require expected child slots", %{
      id: element.id,
      kind: element.kind,
      missing_slot: missing_slot
    })
  end
end
