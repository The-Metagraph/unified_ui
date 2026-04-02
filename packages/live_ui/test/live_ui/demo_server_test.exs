defmodule LiveUi.DemoServerTest do
  use ExUnit.Case, async: false

  @moduletag :capture_log

  test "browser host renders the demo home screen" do
    port = free_port()
    {:ok, _server} = start_supervised({LiveUi.Demo.Server, host: "127.0.0.1", port: port})

    body = wait_for_body("http://127.0.0.1:#{port}/")

    assert body =~ "Live UI Workbench"
    assert body =~ "live_ui package demo"

    assert body =~
             "Browse the package-local demo through the same server-authoritative runtime the package exposes everywhere else."

    assert body =~ "data-phx-main"
    assert body =~ ~s(id="live-ui-demo-category-tabs")
    assert body =~ ~s(data-item-id="button")
    assert body =~ ">Button<"
    refute body =~ "Meaningful Interaction Story"
    refute body =~ "Canonical Signal Preview"
    refute body =~ "No signal captured yet"
    refute body =~ "<h1>Live UI Demo</h1>"
    refute body =~ ">Overview<"
    refute body =~ "Examples:"
    refute body =~ "Native:"
    refute body =~ "Canonical:"
    refute body =~ "Mixed:"
    refute body =~ "Featured demo routes"
  end

  test "browser host deep-links directly to an example" do
    port = free_port()
    {:ok, _server} = start_supervised({LiveUi.Demo.Server, host: "127.0.0.1", port: port})

    body = wait_for_body("http://127.0.0.1:#{port}/examples/button")

    assert body =~ "Button"
    assert body =~ ~s(id="live-ui-demo-widget-button-panel")
    assert body =~ ~s(id="live-ui-demo-widget-button-button")
    assert body =~ ~s(data-live-ui-widget="button")

    assert body =~
             "Browse the package-local demo through the same server-authoritative runtime the package exposes everywhere else."

    refute body =~ "live-ui-demo-example-breadcrumbs"
    refute body =~ ~s(id="live-ui-demo-interaction-grid")
    refute body =~ "Meaningful Interaction Story"
    refute body =~ "Canonical Signal Preview"
    refute body =~ "No signal captured yet"
    refute body =~ "Rendered Preview"
    refute body =~ "Comparison Report"
    assert body =~ ~s(id="live-ui-demo-example-metadata")
    assert body =~ "Category: Foundational | Widget family: Content"
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
