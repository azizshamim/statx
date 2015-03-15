defmodule StatxTest do
  use ExUnit.Case, async: false

  def send_message(socket, message) do
    :ok = :gen_udp.send(socket, {127,0,0,1}, 1516, message)
  end

  def wait_for(ms) do
    receive do
    after
      ms -> :timeout
    end
  end

  setup do
    Logger.remove_backend(:console)
    :application.stop(:statx)
    :ok = :application.start(:statx)
    Logger.add_backend(:console, flush: true)
    :ok
  end

  setup do
    {:ok, socket} = :gen_udp.open(1515)
    {:ok, socket: socket }
  end

  test :statsd_guage , %{socket: socket} do
    # <metric name>:<value>|g
      1..100
        |> Enum.map(fn(x) ->
                      socket |> send_message("test.key:#{x}|g")
                    end)
    wait_for(100)
    assert 100 == Statx.Storage.count(:test_key)
  end
end
