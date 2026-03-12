defmodule UnifiedUi.Widgets.DrawingContext do
  @moduledoc """
  Drawing context behaviour used by `canvas` widgets.

  Platform adapters can implement this behaviour to provide
  canvas drawing primitives.
  """

  @type t :: term()

  @callback draw_text(String.t(), integer(), integer()) :: t()
  @callback draw_line(integer(), integer(), integer(), integer(), keyword()) :: t()
  @callback draw_rect(integer(), integer(), integer(), integer()) :: t()
  @callback clear() :: t()
end

defmodule UnifiedUi.Widgets.DrawingContext.Noop do
  @moduledoc false

  @behaviour UnifiedUi.Widgets.DrawingContext

  @impl true
  def draw_text(_text, _x, _y), do: :ok

  @impl true
  def draw_line(_x1, _y1, _x2, _y2, _opts), do: :ok

  @impl true
  def draw_rect(_x, _y, _width, _height), do: :ok

  @impl true
  def clear, do: :ok
end
