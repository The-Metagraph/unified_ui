defmodule LiveUi.Live.EventRouterTest do
  use ExUnit.Case, async: true

  alias LiveUi.Live.EventRouter

  test "rejects malformed payloads before dispatch" do
    assert {:error, error} = EventRouter.normalize("click", %{"widget_kind" => "button"})
    assert error.message =~ "missing required metadata"
    assert error.details.field == "widget_id"
  end

  test "requires a map payload for both standard events and hook payloads" do
    assert {:error, error} = EventRouter.normalize("hook", widget_id: "canvas")
    assert error.message =~ "must be a map"
  end
end
