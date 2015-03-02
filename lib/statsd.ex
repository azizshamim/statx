defmodule Statx.StatsD do
  defmacro __using__(_) do
    quote do
      alias Statx.StatsD
    end
  end
  #@moduledoc File.read!("statsd.md")
  # The statsd spec
  # <metric name>:<value>|<type>
  def process_message(message) do
    message
      |> extract_key
      |> extract_type
      |> extract_metric
  end

  def extract_key(message) do
    [ key | _tail ] = [ 'test.something' , 'foo']
    Dict.put(message, :key, key)
  end

  defp extract_type(message) do
    [ type | _tail ] =  message[:message] |> String.split("|") |> Enum.reverse
    Dict.put(message, :type , type)
  end

  defp extract_metric(message) do
    case message do
      %{:type => "g"} ->
        [ _key, metric ] = message[:message]
                  |> String.split("|")
                  |> List.first
                  |> String.split(":")
        Dict.put(message, :metric, metric)
      _ -> message
    end
  end
end
