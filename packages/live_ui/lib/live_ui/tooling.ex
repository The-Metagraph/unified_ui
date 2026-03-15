defmodule LiveUi.Tooling do
  @moduledoc """
  Package-facing entrypoint for inspection and validation helpers.
  """

  @type workflow :: :reference_examples | :inspection | :validation | :documentation

  @spec workflows() :: [workflow()]
  def workflows do
    [:reference_examples, :inspection, :validation, :documentation]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
