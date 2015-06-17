# Elixir PubSub

This is a Publish-Subscribe utility library that implements a pub-sub mechanism to ease the burden of communication on the business logic processes.

## How to use it

It's very easy to use, an example below.

``` elixir
topic1 = :erlang
topic2 = :elixir

{:ok, pid} = PubSub.start_link()

pid1 = Client.start("Client #1")
pid2 = Client.start("Client #2")
pid3 = Client.start("Client #3")

PubSub.subscribe(pid1, topic1)
PubSub.subscribe(pid2, topic1)
PubSub.subscribe(pid3, topic2)

list1 = PubSub.subscribers(topic1)
list2 = PubSub.subscribers(topic2)

IO.puts "Subscribed to #{topic1}: #{inspect(list1)}"
IO.puts "Subscribed to #{topic2}: #{inspect(list2)}"

PubSub.publish(topic1, "#{topic1} is great!")
PubSub.publish(topic2, "#{topic2} is so cool, dude")
```
