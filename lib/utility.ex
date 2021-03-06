defmodule Utility do

  def sha256_string?(str), do: byte_size(str) == 64

  def reepdm160_string?(str), do: byte_size(str) == 40

  def hash(data, algo) do
    :crypto.hash(algo, data)
  end

  def simulatedBlockChain(n) do
    blockChain =
      Enum.reduce(0..n, [], fn index, acc ->
       if index == 0 do
          genesisBlock = Block.genesis_block()
          [genesisBlock]
         else
          [latestBlock | _] = acc
          data = %Transaction
            {hash: "A7F7DB48D5AC7BD71AD9DACE8B918635B9E3556C46E4843D70BC9B648906D9D7",
            inputs: [["3D79D1C8ED2C0DC7104E94E77C341999BEE6B72591BCD2EE76EA1197DF4C0A8B", 0]],
            outputs: [["95D99EBEBFF758F1ECDD3BEBA2A8BD8C9638A91B", 20],["8EEDD8DA26A9354F2B0034799012B413EF0D817B", 30]],
            public_key: "04A9A2657CD3C52C10B72D29D6B272986B37A37065E9E8BF88C39678FD1DB0BD36CE47A25F541CE5283C699D5B0640240E77ECE44C8DAABED1B7B616A8B3654A43",
            signature: "304502207E460F81DF507D8BCD9491665A67AA954C75315E96409D734070204FBD1EFF5A0221008D87734C6464BD4DAEAE591ADDCA6CD3018DDDF8DD4CBEB350B797F76931358A"}
           nextBlock = Block.generate_next_block(data, latestBlock)
           proofOfWork = ProofOfWork.compute(nextBlock)

           [proofOfWork | acc]
       end
      end)
    blockChain
  end

end
