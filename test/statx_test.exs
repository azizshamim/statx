defmodule Statx.ServerTest do
  use ExUnit.Case

  test "should start a udp socket" do
  #    # VROOM. Start your engines
  #    {:ok , server} = Statx.Server.start_link(1514)
      {:ok, client_socket} = :gen_udp.open(1515)
  #
  #    # Launch missile!
      :ok = :gen_udp.send(client_socket, {127,0,0,1}, 1514, "BOOM!")
  #
      fakeout = receive do
        after 10 ->
          true
        end
      res = :ets.lookup(:packets, 'BOOM!')
      assert([{'BOOM!', 'BANG!'}] == res)
      # Clean up
  #    :ok = Statx.Server.stop(server)
      :gen_udp.close(client_socket)

  end
end
