defmodule Core.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Core.BucketSupervisor,
      {Core.Registry, name: Core.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
