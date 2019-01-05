defmodule KeyPairTest do
  use ExUnit.Case, async: true

  test "generate_key_pair_test" do
    {pk, sk} = KeyPair.generate_key_pair()
    assert pk != nil
    assert sk != nil
  end

  test "verify_signature_test" do
    sagar = Wallet.create()
    inputs = [["some_tx_hash", 0]]
    outputs = [["some_address", 20]]
    transaction = Transaction.new_transaction(sagar, inputs, outputs)

    generated_string_of_transaction  = Transaction.generate_string_from_transaction(transaction)

    assert KeyPair.verify_signature(sagar.public_key, generated_string_of_transaction, transaction.signature)
  end

end