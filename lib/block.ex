defmodule Block do

@type t ::
        %{
          index: integer,
          previousHash: String.t(),
          timeStamp: integer,
          data: Transaction.t(),
          nonce: integer | nil,
          hash: String.t() | nil
        }

defstruct [:index, :previousHash, :timeStamp, :data, :nonce, :hash]

def genesis_block do
  firstTransaction = %Transaction{
    hash: "",
    inputs: [],
    outputs: [],
    public_key: "",
    signature: ""
  }

  %Block{
    index: 0,
    previousHash: "0000000000000000000000000000000000000000000000000000000000000000",
    timeStamp: 311731200,
    data: firstTransaction,
    nonce: 2083236893,
    hash: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
  }
end

def calculate_hash(%Block{index: index, previousHash: previousHash, timeStamp: timeStamp, data: data, nonce: nonce}) do
  "#{index}#{previousHash}#{timeStamp}#{data.hash}#{nonce}"
  |> Utility.hash(:sha256)
  |> Base.encode16()
end

def generate_next_block(data, block \\ BlockChain.latest_block())
def generate_next_block(data, %Block{} = latestBlock) do
  newBlock = %Block{
  index: latestBlock.index + 1,
  previousHash: latestBlock.hash,
  timeStamp: System.system_time(:second),
  data: data
  }

  hash = calculate_hash(newBlock)

  %{newBlock | hash: hash}
end

end