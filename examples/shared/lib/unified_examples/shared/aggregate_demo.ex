defmodule UnifiedExamples.Shared.AggregateDemo do
  @moduledoc """
  Shared launch descriptor support for the aggregate examples demo app.
  """

  @demo_root Path.expand("../../../../demo", __DIR__)

  @spec launch_descriptor(keyword()) :: map()
  def launch_descriptor(opts \\ []) do
    port = Keyword.get(opts, :port, default_port())
    path = "/"
    url = "http://127.0.0.1:#{port}#{path}"

    %{
      directory: "demo",
      cwd: @demo_root,
      argv: ["mix", "phx.server"],
      env: [{"PORT", Integer.to_string(port)}],
      path: path,
      url: url,
      command: "cd #{@demo_root} && PORT=#{port} mix phx.server"
    }
  end

  defp default_port do
    System.get_env("PORT", "4000")
    |> String.to_integer()
  rescue
    ArgumentError -> 4000
  end
end
