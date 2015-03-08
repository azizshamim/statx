defmodule Statx.Storage do
  use GenServer
  use Statx.StatsD

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

  def count do
    GenServer.call(__MODULE__, {:count})
  end

  ## Private
  @doc "Store a key/data pair"
  def handle_cast({:store, data}, ets_name) do
    case :ets.insert(ets_name, {data.timestamp, data} ) do
      true  -> { :noreply, ets_name}
      error -> { :reply,   error, ets_name}
    end
  end

  @doc "Count the keys"
  def handle_call({:count}, _from, ets_name) do
    case :ets.match(ets_name, :"$1") do
      [data] -> {:reply, data, ets_name}
    end
  end

  @doc "Get a key/data pair"
  def handle_call({:get, key}, _from, ets_name) do
    case lookup(ets_name, key) do
      {:reply, data, ^ets_name} -> {:reply, data, ets_name}
      :error -> {:reply, [], ets_name}
    end
  end

  defp lookup(ets_name, key) do
    case :ets.lookup(ets_name, key) do
      [{^key, data}] -> {:reply, data, ets_name}
      [] -> :error
    end
  end
end
