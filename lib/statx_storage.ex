defmodule Statx.Storage do
  use GenServer
  use Statx.StatsD

  @doc ~S"""
  Storage server for the StatX server. This stores the parsed UDP messages into ETS.

  Examples:

  iex> Statx.Storage.store(%{Statx.Message{})
  {:ok, %{Statx.Message{}}
  """
  ## Public Api
  def start_link(ets_name) do
    GenServer.start_link(__MODULE__, ets_name, name: ets_name)
  end

  def init(ets_name) do
    :ets.new(ets_name, [:named_table, :set])
    {:ok, ets_name}
  end

  @doc "Store data into the storage bucket"
  def store(data) do
    GenServer.cast(
      data.key
        |> String.replace(".","_", global: false)
        |> String.to_atom,
      {:store, data}
    )
    {:ok, data}
  end

  @doc "Retrieve data from the storage bucket"
  def get(ets_name, key) do
    GenServer.call(ets_name, {:get, key})
  end

  @doc "Count the data in the storage bucket"
  def count(ets_name) do
    GenServer.call(ets_name, {:count})
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
      data -> {:reply, data |> List.flatten |> length, ets_name}
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
