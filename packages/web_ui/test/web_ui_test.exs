defmodule WebUiTest do
  use ExUnit.Case, async: true

  test "package identity declares the split runtime library boundary" do
    assert %{
             app: :web_ui,
             namespace: WebUi,
             package_path: "packages/web_ui",
             owns_dsl?: false,
             owns_iur_model?: false,
             runtime_split: %{server: WebUi.Server, frontend: WebUi.Frontend}
           } = WebUi.package_identity()
  end

  test "module areas expose the scaffolded package boundaries" do
    assert {:ok, WebUi.Widgets} = WebUi.module_for(:widgets)
    assert {:ok, WebUi.Server} = WebUi.module_for(:server_runtime)
    assert {:ok, WebUi.Frontend} = WebUi.module_for(:frontend_runtime)
    assert {:ok, WebUi.Renderer} = WebUi.module_for(:renderer)
    assert {:ok, WebUi.Transport} = WebUi.module_for(:transport)
    assert {:ok, WebUi.Tooling} = WebUi.module_for(:tooling)
    assert :error = WebUi.module_for(:missing_area)
  end

  test "reference and info surfaces stay aligned with the scaffold" do
    assert %{package: %{app: :web_ui}, runtime: %{server: WebUi.Server, frontend: WebUi.Frontend}} =
             WebUi.reference()

    assert %{runtime_split?: true, assumptions: %{authoritative_server?: true}} = WebUi.info()
  end
end
