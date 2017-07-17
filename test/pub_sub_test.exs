defmodule PubSubTest do
  use ExUnit.Case
  doctest PubSub

  test "processes can subscribe to topics" do
    [pid1, pid2, pid3] = spawn_multiple(3)
    {topic1, topic2} = {:erlang, :elixir}
    PubSub.start_link()
    PubSub.subscribe(pid1, topic1)
    PubSub.subscribe(pid2, topic1)
    PubSub.subscribe(pid3, topic2)

    assert PubSub.subscribers(topic1) == [pid2, pid1]
    assert PubSub.subscribers(topic2) == [pid3]
  end

  def spawn_multiple(times) do
    Enum.map(1..times, fn _ -> spawn(fn -> receive do end end) end)
  end

end
