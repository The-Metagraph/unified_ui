defmodule WebUi.Integration.Phase35ElmRuntimeTransportBridgeTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-040 Elm runtime module exposes deterministic transport ports and command events" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))

    assert main_elm =~ "port sendRuntimeCommand"
    assert main_elm =~ "port runtimeEventReceived"
    assert main_elm =~ "expected_events"
    assert main_elm =~ "runtime.event.ping.v1"
    assert main_elm =~ "runtime.event.send.v1"
    assert main_elm =~ "runtime.event.error.v1"
    refute main_elm =~ "runtime.event.join.v1"
    refute main_elm =~ "runtime.event.joined.v1"
  end

  test "SCN-040 JS bridge emits canonical pong/recv/error events with topic/client guardrails" do
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert bridge_js =~ "sendRuntimeCommand.subscribe"
    assert bridge_js =~ "runtime.event.pong.v1"
    assert bridge_js =~ "runtime.event.recv.v1"
    assert bridge_js =~ "runtime.event.error.v1"
    assert bridge_js =~ "transport.invalid_topic"
    assert bridge_js =~ "transport.unknown_client_event"
    assert bridge_js =~ "runtime.transport.unknown_command"
    refute bridge_js =~ "runtime.event.joined.v1"
  end

  test "SCN-040 report-only frontend validation passes with required harness files present" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_toolchain.sh", "--report-only"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend toolchain wiring checks passed"
  end
end
