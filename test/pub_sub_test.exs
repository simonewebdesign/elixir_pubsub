defmodule PubSubTest do
  use ExUnit.Case

  defmodule Client do
    
    def start(client_name) do
      spawn(fn -> loop(client_name) end)
    end

    def loop(name) do
      receive do
        message -> 
          IO.inspect "#{name} received `#{message}`"
          loop(name)
      end
    end

  end

  test "processes can subscribe to topics" do
    topic1 = :erlang
    topic2 = :elixir

    {:ok, pid} = PubSub.start_link()

    pid1 = Client.start("Client #1")
    pid2 = Client.start("Client #2")
    pid3 = Client.start("Client #3")

    PubSub.subscribe(pid1, topic1)
    PubSub.subscribe(pid2, topic1)
    PubSub.subscribe(pid3, topic2)
    
    subscribers_to_topic1 = PubSub.subscribers(topic1)
    subscribers_to_topic2 = PubSub.subscribers(topic2)

    assert List.first(subscribers_to_topic1) == pid2
    assert List.first(subscribers_to_topic2) == pid3
  end

end
