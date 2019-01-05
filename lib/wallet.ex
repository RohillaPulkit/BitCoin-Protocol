defmodule Wallet do
  @moduledoc """
    Wallet Module implements the create, get_balance and send function
  """

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  def create do
    {pub, priv} = KeyPair.generate_key_pair()

    %Wallet{
      address: KeyPair.public_key_hash(pub),
      public_key: pub,
      private_key: priv
    }
  end

  def get_balance(%Wallet{} = wallet) do
      unspent_output = Ledger.unspent_outputs(wallet)
      balance = unspent_outputs_sum(unspent_output)
      balance
  end

  defp unspent_outputs_sum(unspent_outputs) do
    Enum.reduce(unspent_outputs, 0, fn {_, _, value}, acc -> acc + value end)
  end

  def send(value, recipient, %Wallet{} = wallet) do
      with {:ok, unspent_outputs} <- unspent_outputs(value, wallet),
        inputs <- prepare_inputs_from_the_output(unspent_outputs),
           outputs <- [[recipient, value]],
           outputs <- add_change_to_self(value, outputs, unspent_outputs, wallet) do
#        IO.puts("outputs #{inspect outputs}")
#        IO.puts("inputs #{inspect inputs}")
        transaction = Transaction.new_transaction(wallet, inputs, outputs)
        Ledger.write(transaction)
      end
     # IO.puts("here")
   end

  def prepare_inputs_from_the_output(output) do
    list = Enum.reduce(output, [], fn {transaction_hash, index, _}, acc ->
      Enum.concat(acc, [transaction_hash, index])
    end)
    #IO.puts ("prepare_inputs #{inspect list}")
    [list]
  end

  def add_change_to_self(value, outputs, unspent_outputs, %Wallet{} = wallet) do
    outputs_sum = unspent_outputs_sum(unspent_outputs)
    #IO.puts("output_sum #{inspect outputs_sum}")
    if outputs_sum > value do
      [[wallet.address, outputs_sum - value] | outputs]
    else
    #  IO.puts("here in the else of add_change_to_self")
    #  IO.puts("yaha #{inspect outputs}")
      outputs
    end
  end

  def calculate_sum_of_unspent_outputs(unspent_outputs) do
    Enum.reduce(unspent_outputs, 0, fn {_, _, value}, acc -> acc + value end)
  end

  defp unspent_outputs(target_value, %Wallet{} = wallet) do
    unspent_outputs = Ledger.unspent_outputs(wallet)
    #IO.puts("final unspent outputs #{inspect unspent_outputs}")
    sorted_unspent_outputs = Enum.sort(unspent_outputs, fn {_, _, v1}, {_, _, v2} -> v1 <= v2 end)
    final_unspent_output = select_outputs(sorted_unspent_outputs, target_value, [])
    #IO.puts("final unspent outputs #{inspect final_unspent_output}")
    final_unspent_output
  end

  defp select_outputs(_, value, outputs) when value <= 0 do
    #  IO.puts("bhai, sab sahi hai")
    {:ok, outputs}
  end

  defp select_outputs([], _value, _outputs) do
    #IO.puts("Not enough coins :/")
    {:error, :not_enough_coins}
    end

  defp select_outputs([output | remaining], value, outputs) do
    {_, _, v} = output
    select_outputs(remaining, value - v, [output | outputs])
  end

  def sign(msg, %Wallet{private_key: key}) do
    KeyPair.sign(key, msg)
  end

  def verify(msg, signature, %Wallet{public_key: key}) do
    KeyPair.verify_signature(key, msg, signature)
  end

  def add_free_coin(%Wallet{} = wallet, amount) do
    transaction = Transaction.new_initial_transaction([[wallet.address, amount]])
    block = Block.generate_next_block(transaction)
    mined_block = ProofOfWork.compute(block)
    BlockChain.add_block(mined_block)
  end

end