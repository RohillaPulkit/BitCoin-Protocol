defmodule TransactionTest do
  use ExUnit.Case, async: true

  test "create_transaction_test" do
    sagar = Wallet.create()
    pulkit = Wallet.create()

    inputs = [["some_tx_hash", 0]]
    outputs = [[pulkit.address, 20]]
    transaction = Transaction.new_transaction(sagar, inputs, outputs)

    assert transaction.inputs == inputs
    assert transaction.outputs == outputs
    assert transaction.public_key == sagar.public_key

    generated_string_of_transaction  = Transaction.generate_string_from_transaction(transaction)

    assert KeyPair.verify_signature(sagar.public_key, generated_string_of_transaction, transaction.signature)
  end

  test "create_initial_transaction_test" do

    sagar = Wallet.create()

    outputs = [[sagar.address, 20]]
    transaction = Transaction.new_initial_transaction(outputs)

    assert transaction.inputs == [["0", 0]]
    assert transaction.outputs == outputs
    assert transaction.public_key == nil
    assert transaction.signature == nil
  end

end
