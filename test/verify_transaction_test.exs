defmodule VerifyTransactionTest do
  use ExUnit.Case

  test "check_valid_inputs_format_test" do
    inputs = [["D51AE77904D69EB36A3A1C774DEF03C1A79C1DBC489641597120308FE9FB25E9", 1]]
    assert VerifyTransaction.check_valid_inputs_format?(inputs) == true
  end

  test "check_valid_inputs_format_invalid_case test" do
    inputs = [["D51AE77904D69EB36A3A1C774DEF03C1A79C1DBC489641597120308FE9FB25E", 1]]
    assert VerifyTransaction.check_valid_inputs_format?(inputs) == false
  end

  test "check_valid_outputs_format_test" do
    outputs = [["686bbd7f5a7855c0eaf2875507208ab0ba577db4", 1]]
    assert VerifyTransaction.check_valid_outputs_format?(outputs) == true
  end

  test "check_format_test" do
    transaction = %Transaction{
    inputs: [["D51AE77904D69EB36A3A1C774DEF03C1A79C1DBC489641597120308FE9FB25E9", 1]],
    outputs: [["686bbd7f5a7855c0eaf2875507208ab0ba577db4", 1]]
    }
    assert VerifyTransaction.check_format(transaction) == :ok
  end

end