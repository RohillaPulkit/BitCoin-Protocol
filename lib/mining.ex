defmodule Mining do

  use GenServer

  @server Mining

  @typep pool :: [any()]
  @typep mining :: {} | {reference(), pid(), Block.t()}
  @type state :: {String.t(), pool, mining}

  #GenServer
  def start(address) do
    GenServer.start_link(@server, address)
  end
  def init(address) do
    {:ok, {address,[], {}}}
  end

  #PublicMethods
  def add(pid, data) do
    GenServer.cast(pid, {:mine, data})
  end
  def block_mined(pid, block) do
    GenServer.cast(pid, {:block_mined, block})
  end

  #PrivateMethods
  defp verify_data(data, pool) do
    if Enum.find(pool, &(&1.hash  == data.hash)) != nil do
      {:error, :already_in_pool}
    else
      if data != BlockChain.latest_block().data do
        :ok
        else
        {:error, :already_mined}
      end
    end
  end
  defp add_to_pool({address, pool, {}}, data), do:  {address, pool ++ [data], start_mining(address, data)}
  defp add_to_pool({address, pool, mining}, data), do: {address, pool ++ [data], mining}
  defp remove_from_pool(%Block{data: data}, pool) do
    Enum.reject(pool, &(&1.hash  == data.hash))
  end
  defp mine_next_block(address, []), do: {address, [], {}}
  defp mine_next_block(address, [data | _] = pool), do: {address, pool, start_mining(address, data)}

  defp start_mining(address, data) do
    if data != BlockChain.latest_block().data do
      startTime = System.system_time(:second)
      block = Block.generate_next_block(data)
    {pid, ref} = spawn_monitor(fn -> mine_block(startTime, address, block) end)
# IO.puts("Created #{inspect pid} for mining #{block.index}")
    {ref, pid, block}
    else
      {}
    end
  end
  defp mine_block(startTime, address, %Block{} = b) do
    mined_block = ProofOfWork.compute(b)
    case BlockChain.add_block(mined_block) do
      :ok ->
        channel = Project4.setupPhoenix()
        endTime = System.system_time(:second)
        elapsedTime = endTime - startTime
        block_index = mined_block.index
        timestamp = "#{b.timeStamp}"
        time = "#{inspect elapsedTime}"
        #Project4.pushMessage(channel, " #{inspect self()} Mined block #{mined_block.index}")
        IO.puts("#{address} Mined block #{mined_block.index} in #{inspect elapsedTime} seconds")
        Project4.pushMessage(channel, block_index, address, time, timestamp)
        BroadCaster.sendMinedBlock(mined_block)
#        IO.inspect(BlockChain.all_blocks)
        #Inform others
        :ok

      {:error, _reason} = error ->
        error
    end
  end

  #HandleCalls
  def handle_cast({:mine, data}, {_, pool, _} = state) do
    case verify_data(data, pool) do
      :ok ->
        {:noreply, add_to_pool(state, data)}
      {:error, _} = error ->
        {:noreply, state}
    end
  end
  def handle_cast({:block_mined, %Block{index: i} = b}, {pool, {address, pid, %Block{index: j}} = mining}) when i == j do
    Process.exit(pid, :kill)
    pool = remove_from_pool(b, pool)
    {:noreply, {address, pool, mining}}
  end
  def handle_cast({:block_mined, b}, {address, pool, mining}) do
    pool = remove_from_pool(b, pool)
    {:noreply, {address, pool, mining}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {address, pool, {mref, _, block}}) when ref == mref do
    pool = remove_from_pool(block, pool)
    {:noreply, mine_next_block(address, pool)}
  end

end
