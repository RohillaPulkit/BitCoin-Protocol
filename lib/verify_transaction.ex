defmodule VerifyTransaction do
@moduledoc
"""
Before any transaction is written in the Block, it is verified by this module
"""

  def check_format(%Transaction{} = transaction) do
    if(length(transaction.inputs) == 0) do
      {:error, :no_input}
    end

    if(length(transaction.outputs) == 0) do
      {:error, :no_input}
    end

    if(!check_valid_inputs_format?(transaction.inputs)) do
      {:error, :invalid_input}
    end

    if(!check_valid_outputs_format?(transaction.outputs)) do
      {:error, :invalid_output}
    end
    :ok
  end

  def check_valid_inputs_format?([])do
    true
  end

  def check_valid_inputs_format?([first | remaining]) do
    [transaction_reference, output_index] = first
    if Utility.sha256_string?(transaction_reference) && output_index >= 0 do
      check_valid_inputs_format?(remaining)
    else
      false
    end
  end

  def check_valid_outputs_format?([]) do
    true
  end

  def check_valid_outputs_format?([first| remaining]) do
  [recipient, amount] = first
  if Utility.reepdm160_string?(recipient) && amount > 0 do
    check_valid_outputs_format?(remaining)
  else
    false
  end

  end

end