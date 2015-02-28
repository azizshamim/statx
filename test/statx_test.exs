defmodule StatxTest do
  use ExUnit.Case

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

  test "should start the StatX server", %{socket: socket} do
      # Launch missile!
      :ok = :gen_udp.send(socket, {127,0,0,1}, 1516, "BOOM!")
      res = Statx.Storage.get('BOOM!')
      assert([{'BOOM!', 'BANG!'}] == res)
      # Clean up
      :gen_udp.close(socket)
  end
end
