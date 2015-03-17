defmodule Statx.StatsDTest do
  use ExUnit.Case, async: false

  @doc "<metric name>:<value>|g"
  test :gauge do
    res = Statx.StatsD.process_message("test.gauge:100|g")
    %Statx.Message{
      key: "test.gauge",
      metric: 100,
      type: "g",
      timestamp: _
    } = res
  end

  @doc "<metric name>:<value>|c[|@<sample rate>]"
  test :counter_no_rate do
    res = Statx.StatsD.process_message("test.counter:100|c")
    %Statx.Message{
      key: "test.counter",
      metric: 100,
      type: "c",
      timestamp: _
    } = res
  end
  test :counter_with_rate do
    res = Statx.StatsD.process_message("test.counter:100|c|@0.1")
    %Statx.Message{
      key: "test.counter",
      metric: 100,
      type: "c",
      sample: 0.1,
      timestamp: _
    } = res
  end

  @doc "<metric name>:<value>|ms"
  test :timer do
    res = Statx.StatsD.process_message("test.timer:100|ms")
    %Statx.Message{
      key: "test.timer",
      metric: 100,
      type: "ms",
      timestamp: _
    } = res
  end

  @doc "<metric name>:<value>|h"
  test :histogram do
    res = Statx.StatsD.process_message("test.histogram:100|h")
    %Statx.Message{
      key: "test.histogram",
      metric: 100,
      type: "h",
      timestamp: _
    } = res
  end

  @doc "<metric name>:<value>|m"
  test :meter do
    res = Statx.StatsD.process_message("test.meter:100|m")
    %Statx.Message{
      key: "test.meter",
      metric: 100,
      type: "m",
      timestamp: _
    } = res
  end

  @doc "<metric name>"
  test :meter_inc_by_one do
    # Unimplemented
  end
end
