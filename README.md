# Elixir Publish Subscribe

A Publish-Subscribe utility module that implements a mechanism to ease the burden of communication on your business logic processes.

Fully OTP compliant, based on GenServer.


## Getting started

You need to add this library as a dependency to your `mix.exs` file. For example:

``` elixir
defp deps do
  [{:pubsub, "~> 0.0.1"}]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies.


## API Reference

@type topic :: term
@type msg   :: term
@spec subscribe(topic)         :: :ok
@spec unsubscribe(topic)       :: :ok
@spec publish(topic, message)  :: :ok
@spec subscribers(topic)       :: [pid]
@spec topics()                 :: [topic]


## How to use it

It's very easy to use, an example below.

Assuming your client process looks like this:

``` elixir
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
```

With `PubSub` you can do this:

``` elixir
iex(1)> {topic1, topic2} = {:erlang, :elixir}
{:erlang, :elixir}

iex(2)> {:ok, pid} = PubSub.start_link()
{:ok, #PID<0.99.0>}

iex(3)> {pid1, pid2, pid3} =
...(3)> {
...(3)> Client.start("John"),
...(3)> Client.start("Nick"),
...(3)> Client.start("Tim")
...(3)> }
{#PID<0.106.0>, #PID<0.107.0>, #PID<0.108.0>}

iex(4)> PubSub.subscribe(pid1, topic1)
:ok
iex(5)> PubSub.subscribe(pid2, topic1)
:ok
iex(6)> PubSub.subscribe(pid3, topic2)
:ok

iex(7)> PubSub.publish(topic1, "#{topic1} is great!")
"Nick received `erlang is great!`"
"John received `erlang is great!`"
:ok

iex(8)> PubSub.publish(topic2, "#{topic2} is so cool, dude")
"Tim received `elixir is so cool, dude`"
:ok
```
