defmodule WebUi.Tooling do
  @moduledoc """
  Package-facing entrypoint for maintainer tooling and inspection boundaries.
  """

  @type capability ::
          :package_summary
          | :structure_inspection
          | :validation_placeholders

  @spec capabilities() :: [capability()]
  def capabilities do
    [
      :package_summary,
      :structure_inspection,
      :validation_placeholders
    ]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
