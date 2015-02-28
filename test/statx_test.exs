defmodule StatxTest do
  use ExUnit.Case

  test "should start the StatX server" do
      {:ok, client_socket} = :gen_udp.open(1515)
      # Launch missile!
      :ok = :gen_udp.send(client_socket, {127,0,0,1}, 1514, "BOOM!")

      # FAKE THAT OUT
      fakeout = receive do
        after 10 ->
          true
        end
      res = Statx.Storage.get('BOOM!')
      assert([{'BOOM!', 'BANG!'}] == res)
      # Clean up
      :gen_udp.close(client_socket)
  end
end
