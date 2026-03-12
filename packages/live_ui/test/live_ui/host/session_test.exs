defmodule LiveUi.Host.SessionTest do
  use ExUnit.Case, async: true

  alias LiveUi.ConfigurationError
  alias LiveUi.Session
  alias Phoenix.LiveView.Socket

  test "normalize merges params session socket and extra context into runtime context" do
    socket = %Socket{
      id: "session-1",
      view: LiveUi.TestSupport.WrapperLive,
      assigns: %{__changed__: %{}, live_action: :edit}
    }

    context =
      Session.normalize(
        %{"tab" => "details"},
        %{"user_id" => 12},
        socket,
        %{trace_id: "trace-1", signal_source: "/host/live_ui"}
      )

    assert context == %{
             connected?: false,
             live_action: :edit,
             params: %{"tab" => "details"},
             session: %{"user_id" => 12},
             socket_id: "session-1",
             trace_id: "trace-1",
             signal_source: "/host/live_ui",
             view: LiveUi.TestSupport.WrapperLive
           }
  end

  test "normalize rejects non-map input" do
    assert_raise ConfigurationError,
                 ~r/session normalization expects map params, map session, and map context/,
                 fn ->
                   Session.normalize([], %{}, %Socket{}, %{})
                 end
  end
end
