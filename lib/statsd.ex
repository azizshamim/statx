defmodule Statx.Message do
  defstruct type: nil, metric: nil, key: nil, sample: nil, timestamp: nil
end

defmodule Statx.StatsD do
  require Logger

  @doc ~S"""
  Parse a statsd message according to https://github.com/b/statsd_spec

  #### Supported statsd
    * gauges
    * counters
    * counters w/ sample rate
    * timer
    * histogram
    * meter

  ### Example
  iex> Statx.StatsD.process_message("test.meter:100|m")
  %Statx.Message{ key: "test.meter", metric: 100, type: "m", timestamp: _ }
  """

  defmacro __using__(_) do
    quote do
      alias Statx.StatsD
    end
  end

  @doc "Process the message #   <metric name>:<value>|<type>"
  # Sometimes we send it a bitstring, make it a list
  def process_message(message) when is_bitstring(message) do
    message
      |> String.split(~r/(\||:)/)
      |> process_message
  end

  def process_message(message) when is_list(message),do: _process_message(message)

  @doc "Process the message <metric name>:<value>|c|@<samplerate>"
  defp _process_message(message) when length(message) == 4 do
    [key, metric, type, sample] = message
    Logger.debug "parsed statsd: #{to_string(message)}"
    %Statx.Message{timestamp: :erlang.now}
      |> Map.put(:key, key)
      |> Map.put(:metric, metric |> String.to_integer)
      |> Map.put(:type, type)
      |> Map.put(:sample, sample |> String.lstrip(?@) |> String.to_float)
  end

  defp _process_message(message) when length(message) == 3 do
    [key, metric, type] = message
    Logger.debug "parsed statsd: #{to_string(message)}"
    %Statx.Message{timestamp: :erlang.now}
      |> Map.put(:key, key)
      |> Map.put(:metric, metric |> String.to_integer)
      |> Map.put(:type, type)
  end

  defp reconstruct_message(parsed) do
    case parsed do
      %Statx.Message{sample: nil} -> "#{parsed.key}:#{parsed.metric}|#{parsed.type}"
      _ -> "#{parsed.key}:#{parsed.metric}|#{parsed.type}|@#{parsed.rate}"
    end
  end

end
