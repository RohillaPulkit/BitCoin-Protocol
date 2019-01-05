defmodule BroadCaster do

  def startMining(data) do
    miners = Miners.get_all()
    Enum.each(miners,
      fn miner ->
        Mining.add(miner, data)
      end)
  end

  def sendMinedBlock(block) do
    miners = Miners.get_all()
    Enum.each(miners,
      fn miner ->
          Mining.block_mined(miner, block)
      end)
  end

end