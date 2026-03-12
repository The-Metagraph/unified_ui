defmodule UnifiedUi.Adapters.Shared do
  @moduledoc """
  Shared utility functions for all platform renderers.

  This module provides common functionality for working with IUR trees:
  * Tree traversal with pre/post-order options
  * Element lookup by ID
  * Style collection
  * Tree validation and inspection

  These utilities are pure functions with no side effects, making them
  easy to test and reason about.

  ## Examples

  Traverse an IUR tree:

      iex> Shared.traverse_iur(iur_tree, fn element, acc -> [element | acc] end, [])
      [%VBox{...}, %Text{...}, %Button{...}]

  Find an element by ID:

      iex> Shared.find_by_id(iur_tree, :submit_button)
      %Button{id: :submit_button, label: "Submit"}

  Collect all styles:

      iex> Shared.collect_styles(iur_tree)
      [%Style{fg: :cyan}, %Style{bg: :blue, attrs: [:bold]}]

  """

  alias UnifiedIUR.Element

  @type element :: UnifiedUi.Renderer.iur_element()
  @type accumulator :: term()
  @type traversal_callback :: (element(), accumulator() -> accumulator())
  @type traversal_order :: :pre | :post | :both

  @doc """
  Traverses an IUR tree and applies a callback function to each element.

  The traversal can be in pre-order (parent before children), post-order
  (children before parent), or both directions.

  ## Parameters

  * `iur_tree` - The root element to traverse
  * `callback` - Function called for each element `(element, acc -> acc)`
  * `initial` - Initial accumulator value
  * `opts` - Optional parameters:
    * `:order` - Traversal order: `:pre`, `:post`, or `:both` (default: `:pre`)

  ## Returns

  The final accumulator value after traversal.

  ## Examples

  Pre-order traversal (default):

      iex> traverse_iur(vbox, fn el, acc -> [el | acc] end, [])
      [%VBox{...}, %Text{...}, %Button{...}]

  Post-order traversal:

      iex> traverse_iur(vbox, fn el, acc -> [el | acc] end, [], order: :post)
      [%Text{...}, %Button{...}, %VBox{...}]

  Counting elements:

      iex> traverse_iur(vbox, fn _el, acc -> acc + 1 end, 0)
      3

  Collecting element types:

      iex> traverse_iur(vbox, fn el, acc -> [Element.metadata(el).type | acc] end, [])
      [:vbox, :text, :button]

  """
  @spec traverse_iur(element(), traversal_callback(), accumulator(), keyword()) :: accumulator()
  def traverse_iur(iur_tree, callback, initial \\ [], opts \\ []) do
    order = Keyword.get(opts, :order, :pre)

    do_traverse(iur_tree, callback, initial, order)
  end

  @doc """
  Finds an element in the IUR tree by its ID.

  Performs a depth-first search for the first element with a matching ID.

  ## Parameters

  * `iur_tree` - The root element to search
  * `id` - The element ID to find (atom)

  ## Returns

  * `{:ok, element}` - Element found
  * `:error` - No element with that ID exists

  ## Examples

      iex> find_by_id(iur_tree, :submit_button)
      {:ok, %Button{id: :submit_button, ...}}

      iex> find_by_id(iur_tree, :nonexistent)
      :error

  """
  @spec find_by_id(element(), atom()) :: {:ok, element()} | :error
  def find_by_id(iur_tree, id) when is_atom(id) do
    result =
      traverse_iur(iur_tree, fn element, acc ->
        metadata = Element.metadata(element)
        if Map.get(metadata, :id) == id do
          {:halt, {:found, element}}
        else
          {:cont, acc}
        end
      end, nil, order: :pre)

    case result do
      {:found, element} -> {:ok, element}
      _ -> :error
    end
  end

  @doc """
  Finds an element by ID, raising if not found.

  Like `find_by_id/2` but returns the element directly or raises an error.

  ## Examples

      iex> find_by_id!(iur_tree, :submit_button)
      %Button{id: :submit_button, ...}

      iex> find_by_id!(iur_tree, :nonexistent)
      ** (RuntimeError) Element with ID :nonexistent not found

  """
  @spec find_by_id!(element(), atom()) :: element()
  def find_by_id!(iur_tree, id) do
    case find_by_id(iur_tree, id) do
      {:ok, element} -> element
      :error -> raise "Element with ID #{inspect(id)} not found"
    end
  end

  @doc """
  Collects all style definitions from an IUR tree.

  Traverses the tree and collects all non-nil style structs from elements.

  ## Parameters

  * `iur_tree` - The root element to collect styles from

  ## Returns

  A list of `UnifiedIUR.Style` structs.

  ## Examples

      iex> collect_styles(iur_tree)
      [%Style{fg: :cyan}, %Style{bg: :blue, attrs: [:bold]}]

  """
  @spec collect_styles(element()) :: [UnifiedIUR.Style.t()]
  def collect_styles(iur_tree) do
    traverse_iur(iur_tree, fn element, acc ->
      metadata = Element.metadata(element)
      style = Map.get(metadata, :style)

      if style do
        [style | acc]
      else
        acc
      end
    end, [], order: :pre)
    |> Enum.reverse()
  end

  @doc """
  Counts the total number of elements in an IUR tree.

  Counts both widgets and layouts.

  ## Parameters

  * `iur_tree` - The root element to count

  ## Returns

  The total count of elements in the tree.

  ## Examples

      iex> count_elements(iur_tree)
      5

  """
  @spec count_elements(element()) :: non_neg_integer()
  def count_elements(iur_tree) do
    traverse_iur(iur_tree, fn _element, acc -> acc + 1 end, 0, order: :pre)
  end

  @doc """
  Counts elements by type in an IUR tree.

  Returns a map with element types as keys and counts as values.

  ## Parameters

  * `iur_tree` - The root element to analyze

  ## Returns

  A map like `%{text: 2, button: 1, vbox: 1}`.

  ## Examples

      iex> count_by_type(iur_tree)
      %{text: 2, button: 1, vbox: 1, hbox: 1}

  """
  @spec count_by_type(element()) :: %{atom() => non_neg_integer()}
  def count_by_type(iur_tree) do
    traverse_iur(iur_tree, fn element, acc ->
      type = Element.metadata(element).type
      Map.update(acc, type, 1, &(&1 + 1))
    end, %{}, order: :pre)
  end

  @doc """
  Gets all element IDs from an IUR tree.

  Returns a list of all unique IDs in the tree, in order of discovery.

  ## Parameters

  * `iur_tree` - The root element to extract IDs from

  ## Returns

  A list of atom IDs.

  ## Examples

      iex> get_all_ids(iur_tree)
      [:main_container, :greeting, :submit_button]

  """
  @spec get_all_ids(element()) :: [atom()]
  def get_all_ids(iur_tree) do
    traverse_iur(iur_tree, fn element, acc ->
      metadata = Element.metadata(element)
      id = Map.get(metadata, :id)

      if id do
        [id | acc]
      else
        acc
      end
    end, [], order: :pre)
    |> Enum.reverse()
  end

  @doc """
  Validates an IUR tree for common issues.

  Checks for:
  * Duplicate IDs
  * Nil IDs on TextInput widgets (required)
  * Valid layout children (not empty lists for layouts with children)
  * Circular references (not applicable to current IUR structure)

  ## Parameters

  * `iur_tree` - The root element to validate

  ## Returns

  * `:ok` - Tree is valid
  * `{:error, issues}` - List of validation issues

  ## Examples

      iex> validate_iur(iur_tree)
      :ok

      iex> validate_iur(invalid_tree)
      {:error, [:duplicate_id, :missing_id_on_text_input]}

  """
  @spec validate_iur(element()) :: :ok | {:error, [atom()]}
  def validate_iur(iur_tree) do
    issues = []

    # Check for duplicate IDs
    ids = get_all_ids(iur_tree)
    duplicate_ids = ids -- Enum.uniq(ids)
    issues = if Enum.empty?(duplicate_ids), do: issues, else: [:duplicate_id | issues]

    # Check for nil IDs on TextInput (required)
    nil_text_input_ids = traverse_iur(iur_tree, fn element, acc ->
      metadata = Element.metadata(element)
      if metadata.type == :text_input and is_nil(Map.get(metadata, :id)) do
        [:missing_id_on_text_input | acc]
      else
        acc
      end
    end, [], order: :pre)

    issues = if Enum.empty?(nil_text_input_ids), do: issues, else: [:missing_id_on_text_input | issues]

    # Check for empty layouts (layouts should have children or be intentionally empty)
    empty_layout_ids = traverse_iur(iur_tree, fn element, acc ->
      metadata = Element.metadata(element)
      has_children = case Element.children(element) do
        nil -> false
        [] -> false
        _ -> true
      end

      if metadata.type in [:vbox, :hbox] and not has_children do
        [:empty_layout | acc]
      else
        acc
      end
    end, [], order: :pre)

    issues = if Enum.empty?(empty_layout_ids), do: issues, else: [:empty_layout | issues]

    case issues do
      [] -> :ok
      _ -> {:error, Enum.reverse(issues)}
    end
  end

  # Private functions

  defp do_traverse(element, callback, acc, order) do
    # Apply callback in pre-order if requested
    {status, acc} = if order in [:pre, :both] do
      case callback.(element, acc) do
        {:cont, new_acc} -> {:cont, new_acc}
        {:halt, result} -> {:halt, result}
        :continue -> {:cont, acc}
        other -> {:cont, other}
      end
    else
      {:cont, acc}
    end

    # Return early if halted
    if status == :halt do
      acc
    else
      # Traverse children
      children = Element.children(element)
      acc = traverse_children(children, callback, acc, order)

      # Check if traversal was halted during children traversal
      case acc do
        {:halt, _} -> acc
        _ ->
          # Apply callback in post-order if requested
          if order == :post or order == :both do
            case callback.(element, acc) do
              {:cont, new_acc} -> new_acc
              {:halt, result} -> result
              :continue -> acc
              other -> other
            end
          else
            acc
          end
      end
    end
  end

  # Traverse children, handling early halt
  defp traverse_children(children, callback, acc, order) do
    Enum.reduce_while(children, acc, fn child, child_acc ->
      case do_traverse(child, callback, child_acc, order) do
        {:halt, _} = halted -> {:halt, halted}
        result -> {:cont, result}
      end
    end)
  end
end
