defmodule LiveUi.DemoServerTest do
  use ExUnit.Case, async: false

  @moduletag :capture_log

  test "browser host renders the demo home screen" do
    port = free_port()
    {:ok, _server} = start_supervised({LiveUi.Demo.Server, host: "127.0.0.1", port: port})

    body = wait_for_body("http://127.0.0.1:#{port}/")

    assert body =~ "Live UI Workbench"
    assert body =~ "data-phx-main"
    assert body =~ "Overview"
  end

  test "browser host deep-links directly to an example" do
    port = free_port()
    {:ok, _server} = start_supervised({LiveUi.Demo.Server, host: "127.0.0.1", port: port})

    body = wait_for_body("http://127.0.0.1:#{port}/examples/native_styled_profile")

    assert body =~ "Native Styled Profile"
    assert body =~ "Focused example"
  end

  defp wait_for_body(url, attempts \\ 20)

  defp wait_for_body(_url, 0) do
    flunk("demo server did not become ready in time")
  end

  defp wait_for_body(url, attempts) do
    case System.cmd("curl", ["--fail", "--silent", "--show-error", url]) do
      {body, 0} ->
        body

      _other ->
        Process.sleep(50)
        wait_for_body(url, attempts - 1)
    end
  end

  defp free_port do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, active: false, packet: :raw, reuseaddr: true])
    {:ok, port} = :inet.port(socket)
    :ok = :gen_tcp.close(socket)
    port
  end
end
