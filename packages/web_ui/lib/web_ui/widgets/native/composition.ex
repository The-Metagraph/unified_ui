defmodule WebUi.Widgets.Native.Composition do
  @moduledoc """
  Composition helpers for native web_ui widgets.

  Provides utilities for composing widgets together into screens
  and managing slots.
  """

  alias WebUi.Widgets.Native.Widget

  @type slot_name :: atom()
  @type slot_content :: [Widget.t()]

  @doc """
  Creates a slot with the given name and content.
  """
  @spec slot(slot_name(), slot_content()) :: {slot_name(), slot_content()}
  def slot(name, content \\ []) when is_atom(name) and is_list(content) do
    {name, content}
  end

  @doc """
  Adds a widget to a slot.
  """
  @spec add_to_slot({slot_name(), slot_content()}, Widget.t()) :: {slot_name(), slot_content()}
  def add_to_slot({name, content}, widget) do
    {name, [widget | content]}
  end

  @doc """
  Merges multiple slots into a slots map.
  """
  @spec merge_slots([{slot_name(), slot_content()}]) :: map()
  def merge_slots(slots) when is_list(slots) do
    Enum.into(slots, %{})
  end

  @doc """
  Validates that all required slots are present.
  """
  @spec validate_required_slots(map(), [slot_name()]) :: :ok | {:error, {slot_name(), :missing}}
  def validate_required_slots(slots, required) when is_map(slots) and is_list(required) do
    case Enum.find(required, fn name -> not Map.has_key?(slots, name) end) do
      nil -> :ok
      missing -> {:error, {missing, :missing}}
    end
  end

  @doc """
  Creates a screen from a root widget and slots.
  """
  @spec screen(Widget.t(), map()) :: map()
  def screen(root_widget, slots \\ %{}) do
    %{
      root: root_widget,
      slots: slots,
      created_at: DateTime.utc_now()
    }
  end

  @doc """
  Finds a widget by ID in a screen hierarchy.
  """
  @spec find_widget(map(), atom()) :: {:ok, Widget.t()} | {:error, :not_found}
  def find_widget(screen, widget_id) when is_map(screen) and is_atom(widget_id) do
    # Check root widget
    if screen.root.id == widget_id do
      {:ok, screen.root}
    else
      # Search in slots
      find_in_slots(screen.slots, widget_id)
    end
  end

  defp find_in_slots(slots, widget_id) do
    results =
      slots
      |> Enum.flat_map(fn {_name, widgets} -> widgets end)
      |> Enum.find(fn widget -> widget.id == widget_id end)

    case results do
      nil -> {:error, :not_found}
      widget -> {:ok, widget}
    end
  end

  @doc """
  Lists all widgets in a screen hierarchy.
  """
  @spec list_widgets(map()) :: [Widget.t()]
  def list_widgets(screen) when is_map(screen) do
    [screen.root | list_slot_widgets(screen.slots)]
  end

  defp list_slot_widgets(slots) do
    slots
    |> Enum.flat_map(fn {_name, widgets} -> widgets end)
  end
end
