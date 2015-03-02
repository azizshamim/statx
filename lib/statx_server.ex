defmodule Statx.Server do
  use GenServer

  ## Public API
  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  ## Private API
  @doc "Server starting"
  def init(port) do
    {:ok, socket } = :gen_udp.open(port)
    {:ok, socket }
  end

  @doc "Handle messages from the UDP socket"
  def handle_info({:udp, _socket, _ip, _port, data}, socket) do
    data |> List.to_string
      |> (&(%{ :message => &1 })).()
      |> Statx.StatsD.process_message
      |> Statx.Storage.store
    {:noreply, socket}
  end

  @doc "Shuts down the server"
  def handle_call(:stop, _from, socket) do
    status = terminate("stopping", socket)
    {:stop, :normal, status, socket}
  end

  @doc "Deconstruct safely"
  def terminate(_reason, socket) do
    :gen_udp.close(socket)
    :ok
  end
end
