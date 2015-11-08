# Elixir Publish/Subscribe

A Publish/Subscribe utility module that frees your business logic processes from the burden of communication.


## Getting started

Add pubsub as a dependency to your `mix.exs` file:

``` elixir
defp deps do
  [
    {:pubsub, "~> 0.0.2"}
  ]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies.


## Examples

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

## API Reference

http://hexdocs.pm/pubsub/0.0.2/PubSub.html
