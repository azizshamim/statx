defmodule Statx do
  use Application

  def start(_type, _args) do
    Statx.ServerSupervisor.start_link()
  end
end
