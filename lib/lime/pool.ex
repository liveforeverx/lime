defmodule Lime.Pool do
  @behaviour :sbroker
  alias Lime.Pool
  alias Lime.Worker
  defstruct [broker: nil, workers: nil]

  def start() do
    {:ok, broker} = start_link
    workers = for _ <- 1..:erlang.system_info(:schedulers) do
      {:ok, pid} = Lime.Worker.start_link(broker)
      pid
    end
    %Pool{broker: broker, workers: workers}
  end

  def start_link, do: :sbroker.start_link(__MODULE__, :undefined, [{:time_unit, :milli_seconds}])
  def sync_all(pool),                    do: Enum.map(pool.workers, &Worker.sync/1)
  def set_state(pool, state),            do: Enum.map(pool.workers, &Worker.set_state(&1, state))
  def run(pool, module, function, args), do: Worker.run(pool.broker, module, function, args)

  @doc false
  def init(_opts) do
    client_queue = {:sbroker_codel_queue, {:out, 1_000, 1_000, :drop, 512}}
    worker_queue = {:sbroker_drop_queue, {:out_r, :drop, :infinity}}
    {:ok, {client_queue, worker_queue, 100}}
  end
end
