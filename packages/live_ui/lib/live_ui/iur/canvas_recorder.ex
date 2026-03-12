defmodule LiveUi.IUR.CanvasRecorder do
  @moduledoc """
  Records canvas drawing operations into a serializable instruction list.
  """

  @operations_key {__MODULE__, :operations}

  @spec record((module() -> term()) | nil) :: [map()]
  def record(nil), do: []

  def record(draw_fun) when is_function(draw_fun, 1) do
    Process.put(@operations_key, [])

    try do
      _ = draw_fun.(__MODULE__)
      current_operations()
    rescue
      error -> [%{"op" => "error", "message" => Exception.message(error)}]
    after
      Process.delete(@operations_key)
    end
  end

  def record(other), do: [%{"op" => "unsupported", "value" => inspect(other)}]

  def clear do
    push_operation(%{"op" => "clear"})
    __MODULE__
  end

  def draw_text(text, x, y) do
    push_operation(%{"op" => "text", "text" => to_string(text), "x" => x, "y" => y})
    __MODULE__
  end

  def draw_line(x1, y1, x2, y2, opts \\ []) do
    push_operation(%{
      "op" => "line",
      "from" => [x1, y1],
      "to" => [x2, y2],
      "opts" => normalize_opts(opts)
    })

    __MODULE__
  end

  def draw_rect(x, y, width, height) do
    push_operation(%{"op" => "rect", "x" => x, "y" => y, "width" => width, "height" => height})
    __MODULE__
  end

  defp current_operations do
    @operations_key
    |> Process.get([])
    |> Enum.reverse()
  end

  defp push_operation(operation) do
    operations = Process.get(@operations_key, [])
    Process.put(@operations_key, [operation | operations])
  end

  defp normalize_opts(opts) when is_list(opts) do
    if Keyword.keyword?(opts) do
      Enum.into(opts, %{}, fn {k, v} -> {to_string(k), v} end)
    else
      inspect(opts)
    end
  end

  defp normalize_opts(opts), do: inspect(opts)
end
