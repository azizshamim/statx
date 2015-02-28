defmodule Statx do
  use Application

  def start(_type, _args) do
    Statx.Supervisor.start_link()
  end
end
