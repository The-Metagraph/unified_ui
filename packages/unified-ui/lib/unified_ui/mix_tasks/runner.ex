defmodule UnifiedUi.MixTasks.Runner do
  @moduledoc false

  @doc """
  Re-enables and runs a Mix task with the given arguments.
  """
  @spec run_task(String.t(), [String.t()]) :: any()
  def run_task(task, args) do
    Mix.Task.reenable(task)
    Mix.Task.run(task, args)
  end
end
