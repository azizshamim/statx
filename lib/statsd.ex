defmodule Statx.Message do
  defstruct type: nil, metric: nil, key: nil, sample: nil, timestamp: nil
end

defmodule Statx.StatsD do
  require Logger

  defmacro __using__(_) do
    quote do
      alias Statx.StatsD
    end
  end

  # https://github.com/b/statsd_spec
  #   <metric name>:<value>|<type>
  def process_message(message) when is_bitstring(message) do
    message
      |> String.split(~r/(\||:)/)
      |> process_message
  end

  def process_message(message) when is_list(message) do
    _process_message(message)
  end

  def _process_message(message) when length(message) == 4 do
    [key, metric, type, sample] = message
    %Statx.Message{timestamp: :erlang.now}
      |> Map.put(:key, key)
      |> Map.put(:metric, metric |> String.to_integer)
      |> Map.put(:type, type)
      |> Map.put(:sample, sample |> String.lstrip(?@) |> String.to_float)
  end

  def _process_message(message) when length(message) == 3 do
    [key, metric, type] = message
    %Statx.Message{timestamp: :erlang.now}
      |> Map.put(:key, key)
      |> Map.put(:metric, metric |> String.to_integer)
      |> Map.put(:type, type)
  end
end
