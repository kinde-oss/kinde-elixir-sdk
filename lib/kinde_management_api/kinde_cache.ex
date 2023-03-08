defmodule KindeManagementAPI.KindeCache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    table_id = :ets.new(:kinde_cache, [:set, :public])
    {:ok, %{table_id: table_id, state: []}}
  end

  def get_data(pid) do
    {:ok, state} = GenServer.call(pid, :get_data)
    state
  end

  def handle_call({:get_kinde_data, key}, _from, %{table_id: table_id, state: _state} = state) do
    data = :ets.lookup(table_id, key)
    {:reply, data, state}
  end

  def handle_cast({:add_kinde_data, data}, %{table_id: table_id, state: _state} = state) do
    :ets.insert(table_id, data)
    {:noreply, state}
  end
end
