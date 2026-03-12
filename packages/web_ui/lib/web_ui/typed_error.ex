defmodule WebUi.TypedError do
  @moduledoc """
  Canonical typed error envelope used by boundary modules.
  """

  @enforce_keys [:error_code, :category, :retryable, :correlation_id]
  defstruct [:error_code, :category, :retryable, :details, :correlation_id]

  @type t :: %__MODULE__{
          error_code: String.t(),
          category: String.t(),
          retryable: boolean(),
          details: map() | nil,
          correlation_id: String.t()
        }

  @spec new(String.t(), String.t(), boolean(), map() | nil, String.t()) :: t()
  def new(error_code, category, retryable, details \\ nil, correlation_id \\ "unknown")
      when is_binary(error_code) and is_binary(category) and is_boolean(retryable) and
             (is_map(details) or is_nil(details)) and is_binary(correlation_id) do
    %__MODULE__{
      error_code: error_code,
      category: category,
      retryable: retryable,
      details: details,
      correlation_id: correlation_id
    }
  end
end
