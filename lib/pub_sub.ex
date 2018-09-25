defmodule PubSub do
  @moduledoc """
  Publish-Subscribe utility process. Use `start_link/0` to start it:

      PubSub.start_link()
  """

  use GenServer

  @type topic :: atom
  @type message :: any

  ## Client API

  @doc """
  Starts the server.
  """
  @spec start_link() :: GenServer.on_start()
  @spec start_link(list) :: GenServer.on_start()
  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, [{:name, __MODULE__}])
  end

  @doc """
  Subscribes a process to the given topic.

  ## Example

      iex> pid = self()
      iex> PubSub.subscribe(pid, :my_topic)
      :ok
  """
  @spec subscribe(pid, topic) :: :ok
  def subscribe(pid, topic) do
    GenServer.cast(__MODULE__, {:subscribe, %{topic: topic, pid: pid}})
  end

  @doc """
  Unsubscribes a process from a given topic.

  ## Example

      iex> pid = self()
      iex> PubSub.unsubscribe(pid, :my_topic)
      :ok
  """
  @spec unsubscribe(pid, topic) :: :ok
  def unsubscribe(pid, topic) do
    GenServer.cast(__MODULE__, {:unsubscribe, %{topic: topic, pid: pid}})
  end

  @doc """
  Delivers a message to the given topic.

  ## Example

      iex> PubSub.publish(:my_topic, "Hi there!")
      :ok
  """
  @spec publish(topic, message) :: :ok
  def publish(topic, message) do
    GenServer.cast(__MODULE__, {:publish, %{topic: topic, message: message}})
  end

  @doc """
  Returns a list of pids representing the processes that are currently
  subscribed to the given topic.

  ## Example

      iex> pid = self()
      iex> PubSub.subscribe(pid, :my_topic)
      iex> [subscriber] = PubSub.subscribers(:my_topic)
      iex> subscriber == pid
      true
  """
  @spec subscribers(topic) :: [pid]
  def subscribers(topic) do
    GenServer.call(__MODULE__, {:subscribers, topic})
  end

  @doc """
  Returns a list of the current topics.

  ## Example

      iex> pid = self()
      iex> PubSub.subscribe(pid, :my_topic)
      iex> PubSub.subscribe(pid, :your_topic)
      iex> PubSub.topics
      [:my_topic, :your_topic]
  """
  @spec topics() :: [topic]
  def topics() do
    GenServer.call(__MODULE__, {:topics})
  end

  @spec child_spec(list) :: map
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  ## Callbacks

  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def handle_cast({:subscribe, %{topic: topic, pid: pid}}, state) do
    pid = find_process(pid)
    Process.link(pid)
    subscribers = get_subscribers(topic, state)
    new_state = case Enum.any?(subscribers, fn p -> p == pid end) do
      true  -> state
      false -> Map.put(state, topic, [pid | subscribers])
    end
    {:noreply, new_state}
  end

  def handle_cast({:unsubscribe, %{topic: topic, pid: pid}}, state) do
    pid = find_process(pid)
    Process.unlink(pid)
    new_list = get_subscribers(topic, state) |> List.delete(pid)
    new_state = Map.put(state, topic, new_list)
    {:noreply, new_state}
  end

  def handle_cast({:publish, %{topic: topic, message: message}}, state) do
    for subscriber <- get_subscribers(topic, state) do
      send(subscriber, message)
    end
    {:noreply, state}
  end

  def handle_call({:subscribers, topic}, _from, state) do
    {:reply, get_subscribers(topic, state), state}
  end

  def handle_call({:topics}, _from, state) do
    {:reply, get_topics(state), state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    new_state = get_topics(state) |> delete_pid_from_list(pid, state)
    {:noreply, new_state}
  end


  ## Private

  defp delete_pid_from_list([], _pid, state), do: state
  defp delete_pid_from_list([topic | tail], pid, state) do
    new_list = get_subscribers(topic, state) |> List.delete(pid)
    new_state = Map.put(state, topic, new_list)
    delete_pid_from_list(tail, pid, new_state)
  end

  defp get_subscribers(topic, state) do
    Map.get(state, topic, [])
  end

  defp get_topics(state) do
    Map.keys(state)
  end

  defp find_process(pid) when is_pid(pid) do
    pid
  end

  defp find_process(pid) when is_atom(pid) do
    Process.whereis(pid)
  end
end
