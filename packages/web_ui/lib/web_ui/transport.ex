defmodule WebUi.Transport do
  @moduledoc """
  Signal transport and browser bridge for web_ui.

  This area provides:
  - Phoenix channels for real-time communication
  - Signal encoding/decoding between Elixir and Elm
  - Event routing from client to server
  - State synchronization between Phoenix and Elm

  The transport layer ensures that signals flow correctly between
  the Phoenix server and Elm client while maintaining the
  server-authoritative runtime model.
  """
end
