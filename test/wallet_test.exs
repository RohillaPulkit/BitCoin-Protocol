defmodule WalletTest do
  use ExUnit.Case

  #checks the creation of wallet : A wallet should have a public key, private key and an address
  test "create_wallet_test" do
    wallet = Wallet.create()
     %Wallet{public_key: pk, private_key: sk, address: address} = wallet
       assert pk != nil
       assert sk != nil
       assert byte_size(address) == 40
  end

end