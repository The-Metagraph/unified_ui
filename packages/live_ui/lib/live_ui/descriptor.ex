defmodule LiveUi.Descriptor do
  @moduledoc """
  Normalized render node emitted by the IUR interpreter.
  """

  @enforce_keys [:id, :kind]
  defstruct id: nil,
            kind: nil,
            props: %{},
            children: [],
            signal_bindings: []

  @type t :: %__MODULE__{
          id: String.t(),
          kind: String.t(),
          props: map(),
          children: [t()],
          signal_bindings: [map()]
        }
end
