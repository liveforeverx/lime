defmodule Lime.Worker do
  use GenServer
  alias Lime.Worker

  defstruct [broker: nil, state: nil, tag: nil]

  def start_link(broker) do
    GenServer.start_link(__MODULE__, broker)
  end

  def run(pool, module, function, args) do
    case :sbroker.ask(pool) do
      {:go, ref, worker, _, queue_time} ->
        {:ok, {worker, ref}, queue_time}
        send(worker, {:do, module, function, args})
      {:drop, _} ->
        {:error, :noconnect}
    end
  end

  def sync(pid), do: GenServer.call(pid, :sync)

  def set_state(pid, state), do: GenServer.cast(pid, {:set_state, state})

  def init(broker) do
    state = %Worker{broker: broker, state: nil, tag: make_ref()}
    ask_asynk(state)
    {:ok, state}
  end

  def handle_call(:sync, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast({:set_state, state}, s = %{}) do
    {:noreply, %{s | state: state}}
  end

  def handle_info({:do, module, function, args}, state) do
    apply(module, function, args ++ [state.state])
    ask_asynk(state)
    {:noreply, state}
  end

  def handle_info({_tag, {:go, _, _, _, _}}, s) do
    {:noreply, s}
  end

  defp ask_asynk(%{broker: broker, tag: tag}) do
    _ = :sbroker.async_ask_r(broker, self(), tag)
  end
end
