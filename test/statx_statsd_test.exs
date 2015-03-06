defmodule Statx.StatsDTest do
  use ExUnit.Case, async: false

  @doc "<metric name>:<value>|g"
  test :gauge do
    res = Statx.StatsD.process_message(%{message: "test.gauge:100|g"})
    assert res == %{
      key: "test.gauge",
      message: "test.gauge:100|g",
      metric: 100,
      type: "g",
    }
  end

  @doc "<metric name>:<value>|c[|@<sample rate>]"
  test :counter_no_rate do
    res = Statx.StatsD.process_message(%{message: "test.counter:100|c"})
    assert res == %{
      key: "test.counter",
      message: "test.counter:100|c",
      metric: 100,
      type: "c",
    }
  end
  test :counter_with_rate do
    res = Statx.StatsD.process_message(%{message: "test.counter:100|c|@0.1"})
    assert res == %{
      key: "test.counter",
      message: "test.counter:100|c|@0.1",
      metric: 100,
      type: "c",
      sample: 0.1,
    }
  end

  @doc "<metric name>:<value>|ms"
  test :timer do
    res = Statx.StatsD.process_message(%{message: "test.timer:100|ms"})
    assert res == %{
      key: "test.timer",
      message: "test.timer:100|ms",
      metric: 100,
      type: "ms",
    }
  end

  @doc "<metric name>:<value>|h"
  test :histogram do
    res = Statx.StatsD.process_message(%{message: "test.histogram:100|h"})
    assert res == %{
      key: "test.histogram",
      message: "test.histogram:100|h",
      metric: 100,
      type: "h",
    }
  end

  @doc "<metric name>:<value>|m"
  test :meter do
    res = Statx.StatsD.process_message(%{message: "test.meter:100|m"})
    assert res == %{
      key: "test.meter",
      message: "test.meter:100|m",
      metric: 100,
      type: "m",
    }
  end

  @doc "<metric name>"
  test :meter_inc_by_one do
    # Unimplemented
  end
end
