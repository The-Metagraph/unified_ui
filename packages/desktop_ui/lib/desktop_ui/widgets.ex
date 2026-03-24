defmodule DesktopUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native `desktop_ui` widgets.
  """

  alias DesktopUi.Widget
  alias DesktopUi.Widgets.Builder

  @spec families() :: [Widget.family()]
  def families do
    kinds()
    |> Enum.map(&Widget.family_for/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, Widget, Builder]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [:button, :column, :dialog, :menu, :row, :stack, :status, :text, :text_input, :window]
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_contract: :ready,
      registration_surface: :ready,
      direct_native_scaffold: :ready,
      focus_metadata: :ready,
      slot_contracts: :ready,
      style_contracts: :ready
    }
  end

  @spec registration_model() :: map()
  def registration_model do
    %{
      builder: Builder,
      direct_native_only: true,
      canonical_branching: false,
      supported_kinds: kinds(),
      supported_families: families()
    }
  end

  @spec window(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def window(id, title, children \\ [], opts \\ []) do
    Builder.window(id, title, children, opts)
  end

  @spec dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, title, children \\ [], opts \\ []) do
    Builder.dialog(id, title, children, opts)
  end

  @spec column(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def column(id, children \\ [], opts \\ []) do
    Builder.column(id, children, opts)
  end

  @spec row(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def row(id, children \\ [], opts \\ []) do
    Builder.row(id, children, opts)
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Builder.text(id, content, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Builder.button(id, label, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Builder.text_input(id, opts)
  end

  @spec menu(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Builder.menu(id, items, opts)
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, label, opts \\ []) do
    Builder.status(id, label, opts)
  end
end
