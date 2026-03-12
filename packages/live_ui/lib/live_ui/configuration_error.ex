defmodule LiveUi.ConfigurationError do
  @moduledoc """
  Explicit configuration error raised for invalid `live_ui` setup.
  """

  defexception [:message, details: %{}]

  @type t :: %__MODULE__{
          message: String.t(),
          details: map()
        }

  @spec new(String.t(), map()) :: t()
  def new(message, details \\ %{}) when is_binary(message) and is_map(details) do
    %__MODULE__{message: message, details: details}
  end
end
