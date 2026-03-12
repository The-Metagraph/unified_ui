defmodule UnifiedUi.Dsl.StateHelpers do
  @moduledoc """
  Helper functions for common state update patterns in the Elm Architecture.

  These functions are designed to be used in the `update/2` function to create
  new state maps based on the current state. They follow the pattern of returning
  a map containing only the changed keys, which can then be merged into the
  full state.

  ## Examples

  In your update function:

      def update(state, {:increment, :count}) do
        Map.merge(state, StateHelpers.increment(:count))
      end

      def update(state, {:toggle, :active}) do
        Map.merge(state, StateHelpers.toggle(:active))
      end

      def update(state, {:set, {:email, new_email}}) do
        Map.merge(state, StateHelpers.set(:email, new_email))
      end

  Or use the update helpers directly:

      def update(state, {:increment, key}) do
        StateHelpers.apply_update(state, key, &(&1 + 1))
      end

  """

  @doc """
  Returns a map with the given key incremented by 1.

  The key must exist in the state and be a numeric value.

  ## Examples

      iex> StateHelpers.increment(:count, %{count: 5})
      %{count: 6}

      iex> StateHelpers.increment(:step, %{step: -1})
      %{step: 0}

  """
  @spec increment(atom(), map()) :: map()
  def increment(key, state) when is_atom(key) and is_map(state) do
    %{key => Map.get(state, key, 0) + 1}
  end

  @doc """
  Returns a map with the given key incremented by a custom amount.

  ## Examples

      iex> StateHelpers.increment_by(:count, 5, %{count: 10})
      %{count: 15}

  """
  @spec increment_by(atom(), number(), map()) :: map()
  def increment_by(key, amount, state)
      when is_atom(key) and is_number(amount) and is_map(state) do
    %{key => Map.get(state, key, 0) + amount}
  end

  @doc """
  Returns a map with the given boolean key toggled.

  The key must exist in the state and be a boolean value.

  ## Examples

      iex> StateHelpers.toggle(:active, %{active: true})
      %{active: false}

      iex> StateHelpers.toggle(:visible, %{visible: false})
      %{visible: true}

  """
  @spec toggle(atom(), map()) :: map()
  def toggle(key, state) when is_atom(key) and is_map(state) do
    %{key => !Map.get(state, key, false)}
  end

  @doc """
  Returns a map with the given key set to the specified value.

  ## Examples

      iex> StateHelpers.set(:email, "test@example.com", %{})
      %{email: "test@example.com"}

      iex> StateHelpers.set(:count, 42, %{count: 10})
      %{count: 42}

  """
  @spec set(atom(), any(), map()) :: map()
  def set(key, value, _state) when is_atom(key) do
    %{key => value}
  end

  @doc """
  Applies a function to a state key and returns a map with the result.

  ## Examples

      iex> StateHelpers.apply_update(:count, &(&1 * 2), %{count: 5})
      %{count: 10}

      iex> StateHelpers.apply_update(:name, &String.upcase/1, %{name: "john"})
      %{name: "JOHN"}

  """
  @spec apply_update(atom(), (any() -> any()), map()) :: map()
  def apply_update(key, fun, state) when is_atom(key) and is_function(fun, 1) and is_map(state) do
    %{key => fun.(Map.get(state, key))}
  end

  @doc """
  Merges a state update map into the current state.

  This is a convenience function for the common pattern of applying
  multiple state changes at once.

  ## Examples

      iex> state = %{count: 5, active: false, name: "test"}
      iex> updates = %{count: 6, active: true}
      iex> StateHelpers.merge_updates(state, updates)
      %{count: 6, active: true, name: "test"}

  """
  @spec merge_updates(map(), map()) :: map()
  def merge_updates(state, updates) when is_map(state) and is_map(updates) do
    Map.merge(state, updates)
  end

  @doc """
  Returns a map with the key set to nil.

  Useful for clearing optional state values.

  ## Examples

      iex> StateHelpers.clear(:error, %{error: "Something went wrong"})
      %{error: nil}

  """
  @spec clear(atom(), map()) :: map()
  def clear(key, _state) when is_atom(key) do
    %{key => nil}
  end

  @doc """
  Returns a map with an item appended to a list state value.

  If the key doesn't exist or isn't a list, starts a new list.

  ## Examples

      iex> StateHelpers.append(:items, :new_item, %{items: [:a, :b]})
      %{items: [:a, :b, :new_item]}

      iex> StateHelpers.append(:items, :first, %{})
      %{items: [:first]}

  """
  @spec append(atom(), any(), map()) :: map()
  def append(key, item, state) when is_atom(key) and is_map(state) do
    current_list = Map.get(state, key, [])
    %{key => List.wrap(current_list) ++ [item]}
  end

  @doc """
  Returns a map with an item removed from a list state value.

  Removes only the first occurrence of the item.

  ## Examples

      iex> StateHelpers.remove(:items, :b, %{items: [:a, :b, :c]})
      %{items: [:a, :c]}

  """
  @spec remove(atom(), any(), map()) :: map()
  def remove(key, item, state) when is_atom(key) and is_map(state) do
    current_list = List.wrap(Map.get(state, key, []))
    %{key => List.delete(current_list, item)}
  end
end
