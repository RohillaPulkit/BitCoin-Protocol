defmodule BlockChain do
  use GenServer

  @server BlockChain

  #GenServer
  def start() do
      GenServer.start_link(@server, nil, name: @server)
  end
  def init(_) do
    {:ok, [Block.genesis_block()]}
  end

  #PublicMethods
  def latest_block() do
    GenServer.call(@server, :latest_block)
  end
  def all_blocks() do
    GenServer.call(@server, :all_blocks)
  end
  def add_block(block) do
    GenServer.call(@server, {:add_block, block})
  end
  def update_chain(chain) do
    GenServer.call(@server, {:update_chain, chain})
  end

  #PrivateMethods
  def validate_block(previousBlock, block, _) do
    cond do
      previousBlock.index + 1 != block.index ->
        {:error, :invalid_block_index}

      previousBlock.hash != block.previousHash ->
        {:error, :invalid_block_previous_hash}

      ProofOfWork.verify(block.hash) == false ->
        {:error, :proof_of_work_not_verified}

      block.hash != Block.calculate_hash(block) ->
        {:error, :invalid_block_hash}

       true ->
         {:ok}
    end
  end
  def validate_chain([]), do: {:error, :empty_chain}
  def validate_chain([genesisBlock | _] = blockChain) when length(blockChain) == 1 do
    if genesisBlock == Block.genesis_block() do
      :ok
      else
      {:error, :invalid_genesis_block}
    end
  end
  def validate_chain([block | [previousBlock | rest] = chain]) do
    case validate_block(previousBlock, block, chain) do
      {:error, _} = error ->
      error
      _ -> validate_chain([previousBlock | rest])
    end
  end

  #HandleCalls
  def handle_call(:latest_block, _from, chain) do
    [latest | _] = chain
    {:reply, latest, chain}
  end
  def handle_call(:all_blocks, _from, chain) do
    {:reply, chain, chain}
  end
  def handle_call({:add_block, block}, _from, chain) do
    [previousBlock | _] = chain

    case validate_block(previousBlock, block, chain) do
      {:ok} ->
          {:reply, :ok, [block | chain]}
      {:error, message} ->
        {:reply, {:error, message}, chain}
    end


  end
  def handle_call({:update_chain, newChain}, _from, chain) do
    if length(newChain) > length(chain) do
      case validate_chain(newChain) do
        :ok ->
          {:reply, :ok, newChain}
        {:error, _} = error ->
          {:reply, error, chain}
      end
      else
        error = {:error, :invalid_chain}
        {:reply, error, chain}
    end


  end

end