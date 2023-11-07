defmodule KindeSDK.KindeCache do
  @moduledoc """
  Kinde Cache GenServer

  This module defines a GenServer for caching data in the Kinde SDK.
  It provides methods to store and retrieve data from an ETS table for efficient data access.

  ## Usage Example

  To use the Kinde Cache GenServer, you can start it and then interact with it as follows:

  ```elixir
  {:ok, pid} = KindeSDK.KindeCache.start_link()
  KindeSDK.KindeCache.add_kinde_data(pid, {:some_key, "cached_data"})
  data = KindeSDK.KindeCache.get_kinde_data(pid, :some_key)

  This GenServer is designed to help improve the performance of data storage
  and retrieval in Kinde applications.
  """
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
