defmodule Statx.Storage do
  use GenServer

  ## Public Api
  def start_link(ets_name) do
    GenServer.start_link(__MODULE__, ets_name, name: __MODULE__)
  end

  def init(ets_name) do
    :ets.new(ets_name, [:named_table, :set])
    {:ok, ets_name}
  end

  def store(data) do
    GenServer.cast(__MODULE__, {:store, data})
    {:ok, data}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  ## Private
  @doc "Store a key/data pair"
  def handle_cast({:store, data}, ets_name) do
    :ok = :ets.insert(ets_name, data)
    { :noreply, ets_name }
  end

  @doc "Get a key/data pair"
  def handle_call({:get, key}, _from, ets_name) do
    data = :ets.lookup(ets_name, key)
    {:reply, data, ets_name}
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
    :ok = Statx.Storage.store(data)
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
