defmodule BlockChainTest do
  use ExUnit.Case, async: true

  test "genesis block" do
    block = Block.genesis_block()
    {:ok, firstBlock} = Enum.fetch(BlockChain.all_blocks(), -1)
    assert firstBlock == block
  end

  test "add valid block" do
    data = %Transaction
      {hash: "A7F7DB48D5AC7BD71AD9DACE8B918635B9E3556C46E4843D70BC9B648906D9D7",
      inputs: [["3D79D1C8ED2C0DC7104E94E77C341999BEE6B72591BCD2EE76EA1197DF4C0A8B", 0]],
      outputs: [["95D99EBEBFF758F1ECDD3BEBA2A8BD8C9638A91B", 20],["8EEDD8DA26A9354F2B0034799012B413EF0D817B", 30]],
      public_key: "04A9A2657CD3C52C10B72D29D6B272986B37A37065E9E8BF88C39678FD1DB0BD36CE47A25F541CE5283C699D5B0640240E77ECE44C8DAABED1B7B616A8B3654A43",
      signature: "304502207E460F81DF507D8BCD9491665A67AA954C75315E96409D734070204FBD1EFF5A0221008D87734C6464BD4DAEAE591ADDCA6CD3018DDDF8DD4CBEB350B797F76931358A"}
    nextBlock = Block.generate_next_block(data)
    proofOfWork = ProofOfWork.compute(nextBlock)
    assert :ok == BlockChain.add_block(proofOfWork)
  end

  test "reject invalid block" do
    data = %Transaction
      {hash: "A7F7DB48D5AC7BD71AD9DACE8B918635B9E3556C46E4843D70BC9B648906D9D7",
      inputs: [["3D79D1C8ED2C0DC7104E94E77C341999BEE6B72591BCD2EE76EA1197DF4C0A8B", 0]],
      outputs: [["95D99EBEBFF758F1ECDD3BEBA2A8BD8C9638A91B", 20],["8EEDD8DA26A9354F2B0034799012B413EF0D817B", 30]],
      public_key: "04A9A2657CD3C52C10B72D29D6B272986B37A37065E9E8BF88C39678FD1DB0BD36CE47A25F541CE5283C699D5B0640240E77ECE44C8DAABED1B7B616A8B3654A43",
      signature: "304502207E460F81DF507D8BCD9491665A67AA954C75315E96409D734070204FBD1EFF5A0221008D87734C6464BD4DAEAE591ADDCA6CD3018DDDF8DD4CBEB350B797F76931358A"}
    nextBlock = Block.generate_next_block(data)
    proofOfWork = ProofOfWork.compute(nextBlock)

    invalidBlock = %{proofOfWork | index: 5}
    assert {:error, :invalid_block_index} = BlockChain.add_block(invalidBlock)

    invalidBlock = %{proofOfWork | previousHash: "wrong hash"}
    assert  {:error, :invalid_block_previous_hash} = BlockChain.add_block(invalidBlock)

    invalidHash = "0#{proofOfWork.hash}"
    invalidBlock = %{proofOfWork | hash: invalidHash}

    assert {:error, :invalid_block_hash} = BlockChain.add_block(invalidBlock)

    invalidHash = "1#{proofOfWork.hash}"
    invalidBlock = %{proofOfWork | hash: invalidHash}

    assert {:error, :proof_of_work_not_verified} = BlockChain.add_block(invalidBlock)
  end

  test "validate block chain" do
    emptyChain = []
    assert {:error, :empty_chain} = BlockChain.validate_chain(emptyChain)

    data = %Transaction
      {hash: "A7F7DB48D5AC7BD71AD9DACE8B918635B9E3556C46E4843D70BC9B648906D9D7",
      inputs: [["3D79D1C8ED2C0DC7104E94E77C341999BEE6B72591BCD2EE76EA1197DF4C0A8B", 0]],
      outputs: [["95D99EBEBFF758F1ECDD3BEBA2A8BD8C9638A91B", 20],["8EEDD8DA26A9354F2B0034799012B413EF0D817B", 30]],
      public_key: "04A9A2657CD3C52C10B72D29D6B272986B37A37065E9E8BF88C39678FD1DB0BD36CE47A25F541CE5283C699D5B0640240E77ECE44C8DAABED1B7B616A8B3654A43",
      signature: "304502207E460F81DF507D8BCD9491665A67AA954C75315E96409D734070204FBD1EFF5A0221008D87734C6464BD4DAEAE591ADDCA6CD3018DDDF8DD4CBEB350B797F76931358A"}

    invalidGenesisBlock = %Block{
      index: 1,
      previousHash: "0",
      timeStamp: 411731200,
      data: data,
      nonce: 312,
    }
    invalidChain = [invalidGenesisBlock]
    assert {:error, :invalid_genesis_block} = BlockChain.validate_chain(invalidChain)

    genesisBlock = Block.genesis_block()
    chain = [genesisBlock]

    invalidNextBlock = %Block{
    index: 1,
    previousHash: "something",
    timeStamp: 411731200,
    data: data
    }
    invalidChain = [invalidNextBlock | chain]
    assert {:error, :invalid_block_previous_hash} = BlockChain.validate_chain(invalidChain)

    simulatedBlockChain = Utility.simulatedBlockChain(4)
    assert :ok == BlockChain.validate_chain(simulatedBlockChain)
  end

  test "update chain" do
    newChain = Utility.simulatedBlockChain(5)

    assert :ok = BlockChain.update_chain(newChain)

    BlockChain.update_chain(newChain)

    assert BlockChain.all_blocks() == newChain
  end

end