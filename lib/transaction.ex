defmodule Transaction do

  defstruct [
    :hash,
    # a list of list of the form [[previous_tx_hash, output_index]]
    :inputs,
    :public_key,
    :signature,
    # a list of list of the form [[recipient, value]]
    :outputs
  ]

  def new_initial_transaction(outputs) do
    tx = %Transaction{
      outputs: outputs,
      # Initial Transaction so there is no input
      inputs: [["0", 0]]
    }

    %{tx | hash: compute_hash(tx)}
  end

  def new_transaction(%Wallet{} = wallet, inputs, outputs) do
    tx = %Transaction{
      inputs: inputs,
      public_key: wallet.public_key,
      outputs: outputs
    }

    sig = tx |> generate_string_from_transaction() |> Wallet.sign(wallet)

    signed_tx = %{tx | signature: sig}
    %{signed_tx | hash: compute_hash(signed_tx)}
  end

  # convert the input and output to string to take the hash
  def generate_string_from_transaction(%Transaction{} = tx) do
    s = Enum.reduce(tx.inputs ++ tx.outputs, "", fn [str, int], acc ->
        acc <> str <> Integer.to_string(int)
      end)
    "#{s}#{tx.public_key}"
  end

  defp compute_hash(%Transaction{} = tx) do
    "#{generate_string_from_transaction(tx)}#{tx.signature}"
    |> KeyPair.hash(:sha256)
    |> Base.encode16()
  end


end
