# Elixir Publish/Subscribe

[![Build Status](https://travis-ci.org/simonewebdesign/elixir_pubsub.svg?branch=master)](https://travis-ci.org/simonewebdesign/elixir_pubsub) [![Coverage Status](https://coveralls.io/repos/github/simonewebdesign/elixir_pubsub/badge.svg?branch=master)](https://coveralls.io/github/simonewebdesign/elixir_pubsub?branch=master) [![Hex package](https://img.shields.io/hexpm/v/pubsub.svg)](https://hex.pm/packages/pubsub) [![Documentation](https://inch-ci.org/github/simonewebdesign/elixir_pubsub.svg?branch=master)](https://inch-ci.org/github/simonewebdesign/elixir_pubsub) [![Total Downloads](https://img.shields.io/hexpm/dt/pubsub.svg)](https://hex.pm/packages/pubsub)

A Publish/Subscribe utility module that frees your business logic processes from the burden of communication.


## Getting Started

Add `:pubsub` as a dependency to your `mix.exs` file:

``` elixir
defp deps do
  [
    {:pubsub, "~> 1.0"}
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
        IO.puts "#{name} received `#{message}`"
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

https://hexdocs.pm/pubsub/PubSub.html
