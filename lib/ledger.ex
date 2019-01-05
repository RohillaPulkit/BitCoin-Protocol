defmodule Ledger do

  defp get_blockchain() do
    BlockChain.all_blocks()
  end

  def get_all_transactions(chain) do
    Enum.reduce_while(chain,[], fn %{data: data}, acc ->
      case data do
          %Transaction{} ->
          func = &{:cont, [&1 | &2]}
          func.(data, acc)
      end
    end)
  end

  # returns all the unspent output corresponding to a Wallet
  def unspent_outputs(%Wallet{} = wallet) do
    inputs_set = inputs_set()
   # IO.puts( "input_set #{inspect inputs_set}")
   # IO.puts ("wallet_ output #{inspect wallet_outputs(wallet)}")
    Enum.reject(wallet_outputs(wallet), fn {tx_hash, output_index, value } ->
      MapSet.member?(inputs_set, [tx_hash, output_index])
    end)
  end


  def inputs_set do
    reduce_while(MapSet.new(), fn %Transaction{inputs: inputs}, set ->
      {:cont, Enum.reduce(inputs, set, &MapSet.put(&2, &1))}
    end)
  end

  # returns all the output corresponding to the a Particular wallet
  defp wallet_outputs(%Wallet{address: address}) do
    reduce_while([], fn %Transaction{} = tx, acc ->
      {:cont, acc ++ address_outputs1(tx, address)}
    end)
  end

  def address_outputs(%Transaction{hash: hash, outputs: outputs}, address) do
    #IO.puts(inspect outputs)
    indexed_outputs = index_list(outputs)
    Enum.reduce(indexed_outputs, [], fn {index, [recipient, value]}, acc ->
      if recipient == address do
     #   IO.puts ("receipent #{recipient} address #{address}")
        [{hash, index, value} | acc]
      else
        acc
      end
    end)
  end

  defp address_outputs1(%Transaction{hash: hash, outputs: outputs}, address) do
    indexed_outputs = Enum.with_index(outputs)

    Enum.reduce(indexed_outputs, [], fn {[recipient, value], index}, acc ->
      if recipient == address do
        [{hash, index, value} | acc]
      else
        acc
      end
    end)
  end

  def index_list(list) do
  {_ , indexed_list} = Enum.reduce(list, {0, []},
                              fn x, acc ->
                                {count, list} = acc
                                list = Enum.concat(list, [{count, x}])
                                acc = {count+1, list}
                              end)
  indexed_list
  end

  def reduce_while(chain \\ get_blockchain(), acc, func)

  def reduce_while(chain, acc, func) do
    Enum.reduce_while(chain, acc, fn %{data: data}, acc ->
      case data do
        %Transaction{} ->
          func.(data, acc)

        _ ->
          {:cont, acc}
      end
    end)
  end

  def write(%Transaction{} = transaction) do
    BroadCaster.startMining(transaction)
  end

end