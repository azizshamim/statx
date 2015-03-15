defmodule Statx.Supervisor do
  use Supervisor

  @storage_supervisor_name Statx.StorageSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      # Define workers and child supervisors to be supervised
      supervisor(Statx.StorageSupervisor, [[name: :storage_sup]]),
      worker(Statx.Server, [1516])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all]
    supervise(children, opts)
  end
end

defmodule Statx.StorageSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Statx.Storage, [:test_key])
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

end
