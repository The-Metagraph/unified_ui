defmodule LiveUi.Tooling do
  @moduledoc """
  Package-facing entrypoint for inspection and validation helpers.
  """

  alias LiveUi.Examples

  @type workflow :: :reference_examples | :inspection | :validation | :documentation

  @spec workflows() :: [workflow()]
  def workflows do
    [:reference_examples, :inspection, :validation, :documentation]
  end

  @spec examples() :: [map()]
  def examples do
    Examples.catalog()
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
