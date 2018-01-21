defmodule PubSubTest do
  use ExUnit.Case
  doctest PubSub

  setup do
    {:ok, server} = PubSub.start_link()

    on_exit fn ->
      assert_down(server)
      PubSub.terminate(server, :shutdown)
    end
  end

  test "processes can subscribe to topics" do
    [pid1, pid2, pid3] = spawn_multiple(3)
    {topic1, topic2} = {:erlang, :elixir}

    PubSub.subscribe(pid1, topic1)
    PubSub.subscribe(pid2, topic1)
    PubSub.subscribe(pid3, topic2)

    assert PubSub.subscribers(topic1) == [pid2, pid1]
    assert PubSub.subscribers(topic2) == [pid3]
  end

  test "processes can unsubscribe from topics" do
    [pid1, pid2, pid3] = spawn_multiple(3)
    {topic1, topic2} = {:erlang, :elixir}
    PubSub.subscribe(pid1, topic1)
    PubSub.subscribe(pid2, topic1)
    PubSub.subscribe(pid3, topic2)
    PubSub.unsubscribe(pid2, topic1)

    assert PubSub.subscribers(topic1) == [pid1]
    assert PubSub.subscribers(topic2) == [pid3]
  end

  test "processes can subscribe by name" do
    pid = spawn(fn -> receive do end end)
    true = Process.register(pid, :name_a)
    PubSub.subscribe(:name_a, :topic1)
    assert PubSub.subscribers(:topic1) == [pid]
  end

  test "processes can unsubscribe by name" do
    pid = spawn(fn -> receive do end end)
    true = Process.register(pid, :name_b)
    PubSub.subscribe(:name_b, :topic1)
    assert PubSub.subscribers(:topic1) == [pid]
    PubSub.unsubscribe(:name_b, :topic1)
    assert PubSub.subscribers(:topic1) == []
  end

  test "processes can subscribe by name and unsubscribe by pid" do
    pid = spawn(fn -> receive do end end)
    true = Process.register(pid, :name_c)
    PubSub.subscribe(:name_c, :topic1)
    assert PubSub.subscribers(:topic1) == [pid]
    PubSub.unsubscribe(pid, :topic1)
    assert PubSub.subscribers(:topic1) == []
  end

  test "list of current topics can be retrieved" do
    pid = spawn(fn -> receive do end end)
    {topic1, topic2, topic3} = {:elixir, :erlang, :opensource}
    PubSub.subscribe(pid, topic1)
    PubSub.subscribe(pid, topic2)
    PubSub.subscribe(pid, topic3)

    assert PubSub.topics() == [:elixir, :erlang, :opensource]
  end

  test "process can publish a message to a topic" do
    topic = :elixir
    PubSub.subscribe(self(), topic)
    PubSub.publish(topic, "Hello!")
    assert_receive "Hello!"
  end

  test "genserver can be shut down gracefully" do
     pid = spawn(fn -> receive do end end)
     PubSub.subscribe(pid, :my_topic)

     assert Process.exit(pid, :kill) == true
     assert_down(pid)
     assert PubSub.subscribers(:my_topic) == []
  end

  def spawn_multiple(times) do
    Enum.map(1..times, fn _ -> spawn(fn -> receive do end end) end)
  end

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

end
