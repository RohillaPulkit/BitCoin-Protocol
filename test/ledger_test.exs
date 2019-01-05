defmodule LedgerTest do
  use ExUnit.Case

  test "index_list_test" do
    list = ["a", "b", "c"]
    list = Ledger.index_list(list)
    assert list == [{0,"a"}, {1,"b"}, {2,"c"}]
  end

  test "address_outputs_test" do
    transaction = %Transaction{hash: "abcd", outputs: [["abcd", 20]]}
    assert Ledger.address_outputs(transaction, "abcd") == [{"abcd", 0, 20}]
  end

end

