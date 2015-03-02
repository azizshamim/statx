defmodule Statx.Storage do
  use GenServer

  ## Public Api
  def start_link(ets_name) do
    GenServer.start_link(__MODULE__, ets_name, name: __MODULE__)
  end

  def init(ets_name) do
    :ets.new(:packets, [:named_table, :set])
    {:ok, :packets}
  end

  def store(data) do
    GenServer.cast(__MODULE__, {:store, data})
    {:ok, data}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def count do
    GenServer.call(__MODULE__, {:count})
  end

  ## Private
  @doc "Store a key/data pair"
  def handle_cast({:store, data}, _ets_name) do
    case :ets.insert(:packets, data) do
      true  -> { :noreply, :packets}
      error -> { :reply,   error, :packets}
    end
  end

  @doc "Count the keys"
  def handle_call({:count}, _from, _ets_name) do
    case :ets.match(:packets, :"$1") do
      [data] -> {:reply, data, :packets}
    end
  end

  @doc "Get a key/data pair"
  def handle_call({:get, key}, _from, ets_name) do
    case lookup(ets_name, key) do
      {:reply, data, _ets_name} -> {:reply, data, :packets}
      :error -> {:reply, [], :packets}
    end
  end

  defp lookup(ets_name, key) do
    case :ets.lookup(ets_name, key) do
      [{^key, data}] -> {:reply, data, ets_name}
      [] -> :error
    end
  end
end

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
    data
      |> process_message
      |> Statx.Storage.store
    {:noreply, socket}
  end

  @doc "Shuts down the server"
  def handle_call(:stop, _from, socket) do
    status = terminate("stopping", socket)
    {:stop, :normal, status, socket}
  end

  defp process_message(message) do
    {'BOOM!', message}
  end

  @doc "Deconstruct safely"
  def terminate(_reason, socket) do
    :gen_udp.close(socket)
    :ok
  end
end
