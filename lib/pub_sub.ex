defmodule PubSub do
  use GenServer

  @type topic :: binary
  @type message :: binary

  ## Client API

  @doc """
  Starts the server.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [{:name, __MODULE__}])
  end

  @doc """
  Subscribes a process to the given topic.

  ## Example

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
  @spec publish(binary, message) :: :ok
  def publish(topic, message) do
    GenServer.cast(__MODULE__, {:publish, %{topic: topic, message: message}})
  end

  @doc """
  Returns a list of pids representing the processes that are currently
  subscribed to the given topic.
  """
  @spec subscribers(topic) :: [pid]
  def subscribers(topic) do
    GenServer.call(__MODULE__, {:subscribers, topic})
  end

  @doc """
  Returns a list of the current topics.
  """
  @spec topics() :: [topic]
  def topics() do
    GenServer.call(__MODULE__, {:topics})
  end

  # Callbacks

  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def handle_cast({:subscribe, %{topic: topic, pid: pid}}, state) do
    Process.link(pid)
    new_state = Map.put(state, topic, [pid | get_subscribers(topic, state)])
    {:noreply, new_state}
  end

  def handle_cast({:unsubscribe, %{topic: topic, pid: pid}}, state) do
    Process.unlink(pid)
    new_list = unsubscribe_from_topic(topic, state, pid)

    new_state = Map.put(state, topic, new_list)
    {:noreply, new_state}
  end

  def handle_cast({:publish, %{topic: topic, message: message}}, state) do
    for sub <- get_subscribers(topic, state) do
      send(sub, message)
    end
    {:noreply, state}
  end

  def handle_call({:subscribers, topic}, _from, state) do
    {:reply, get_subscribers(topic, state), state}
  end

  def handle_call({:topics}, _from, state) do
    {:reply, get_topics(state), state}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    new_state = get_topics(state) |> remove_from_topic(pid, state)
    {:noreply, new_state}
  end

  def remove_from_topic([], _pid, state), do: state
  def remove_from_topic([topic | tail], pid, state) do
    new_list = unsubscribe_from_topic(topic, state, pid)
    new_state = Map.put(state, topic, new_list)
    remove_from_topic(tail, pid, new_state)
  end

  defp unsubscribe_from_topic(topic, state, pid) do
    get_subscribers(topic, state) |> List.delete(pid)
  end

  defp get_subscribers(topic, state) do
    Dict.get(state, topic, [])
  end

  defp get_topics(state) do
    Dict.keys(state)
  end

end
