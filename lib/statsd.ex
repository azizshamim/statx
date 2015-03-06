defmodule Statx.StatsD do
  defmacro __using__(_) do
    quote do
      alias Statx.StatsD
    end
  end

  # https://github.com/b/statsd_spec
  #   <metric name>:<value>|<type>
  def process_message(message) do
    message
      |> extract_key
      |> extract_metric
      |> extract_type
  end

  def extract_key(message) do
    [ key | _tail ] = message[:message] |> String.split(":")
    Dict.put(message, :key, key)
  end

  defp _extract_metric(message) do
    metric = message[:message]
      |> String.split("|")
      |> List.first
      |> String.split(":")
      |> List.last
    Dict.put(message, :metric, metric |> String.to_integer )
  end

  defp extract_type(message) do
    case message |> split_pipe do
      [ _metric, type ]  -> Dict.put(message, :type , type)
      [ _metric, type, sample ] ->
        message
          |> Dict.put(:type, type)
          |> Dict.put(:sample, sample |> String.lstrip(?@) |> String.to_float )
    end
  end

  defp split_pipe(message) do
    message[:message] |> String.split("|")
  end

  defp extract_metric(message) do
    case message do
      %{:type => "g"} ->
        message |> _extract_metric
      %{:type => "c"} ->
        message |> _extract_metric
      %{:type => "ms"} ->
        message |> _extract_metric
      %{:type => "h"} ->
        message |> _extract_metric
      %{:type => "m"} ->
        message |> _extract_metric
      _ -> 
        message |> _extract_metric
    end
  end
end
