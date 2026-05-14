defmodule TerminalUi.Transport.Error do
  @moduledoc """
  Deterministic transport diagnostics for `terminal_ui`.
  """

  @enforce_keys [:reason, :message]
  defexception [:reason, :message, :details]

  @type t :: %__MODULE__{
          reason: atom(),
          message: String.t(),
          details: map() | nil
        }

  @spec invalid_family(term()) :: t()
  def invalid_family(family) do
    %__MODULE__{
      reason: :invalid_family,
      message: "terminal_ui transport requires a supported canonical interaction family",
      details: %{family: inspect(family)}
    }
  end

  @spec invalid_native_event(term()) :: t()
  def invalid_native_event(value) do
    %__MODULE__{
      reason: :invalid_native_event,
      message: "native terminal events must normalize into the shared terminal interaction model",
      details: %{value: inspect(value)}
    }
  end

  @spec ambiguous_native_event(term()) :: t()
  def ambiguous_native_event(value) do
    %__MODULE__{
      reason: :ambiguous_native_event,
      message: "native terminal input must resolve to one canonical interaction family",
      details: %{value: inspect(value)}
    }
  end

  @spec invalid_payload_mapping(term(), atom()) :: t()
  def invalid_payload_mapping(value, surface) do
    %__MODULE__{
      reason: :invalid_payload_mapping,
      message: "transport payloads must be plain maps before they cross the terminal boundary",
      details: %{value: inspect(value), surface: surface}
    }
  end

  @spec invalid_boundary_signal(term()) :: t()
  def invalid_boundary_signal(value) do
    %__MODULE__{
      reason: :invalid_boundary_signal,
      message: "boundary signals must contain canonical terminal_ui transport extensions",
      details: %{value: inspect(value)}
    }
  end

  @spec missing_boundary_context([atom()]) :: t()
  def missing_boundary_context(fields) do
    %__MODULE__{
      reason: :missing_boundary_context,
      message: "boundary translation requires stable screen and runtime context",
      details: %{fields: fields}
    }
  end

  @spec leaked_backend_detail([atom() | String.t()]) :: t()
  def leaked_backend_detail(keys) do
    %__MODULE__{
      reason: :leaked_backend_detail,
      message:
        "backend-local terminal payload details must not leak into the canonical boundary contract",
      details: %{keys: keys}
    }
  end

  @spec host_route_syntax([atom() | String.t()]) :: t()
  def host_route_syntax(keys) do
    %__MODULE__{
      reason: :host_route_syntax,
      message:
        "host-router and runtime-stack syntax must not cross the terminal_ui navigation boundary",
      details: %{keys: keys}
    }
  end

  @spec unsupported_backend_mode(term()) :: t()
  def unsupported_backend_mode(mode) do
    %__MODULE__{
      reason: :unsupported_backend_mode,
      message: "terminal_ui transport supports only the raw and tty backend modes",
      details: %{backend_mode: inspect(mode)}
    }
  end
end
