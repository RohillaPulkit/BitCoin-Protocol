defmodule User do
  use GenServer

  @timeout :infinity

  def start() do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    wallet = Wallet.create()
    address = wallet.address
    {:ok, miner} = Mining.start(address)
    {:ok, [wallet, miner]}
  end

  def miner(pid), do: GenServer.call(pid, :miner)

  def address(pid), do: GenServer.call(pid, :address)

  def balance(pid), do: GenServer.call(pid, :balance)

  def add_free_coins(pid, amount), do: GenServer.call(pid, {:addFreeCoins, amount}, @timeout)

  def send(sender, amount, recipient), do: GenServer.call(sender, {:send, amount, recipient}, @timeout)

  def handle_call(:miner, _from, [wallet,miner]), do: {:reply, miner, [wallet,miner]}
  def handle_call(:address, _from, [wallet,miner]), do: {:reply, wallet.address, [wallet,miner]}
  def handle_call(:balance, _from, [wallet,miner]), do: {:reply, Wallet.get_balance(wallet), [wallet,miner]}
  def handle_call({:send, amount, recipient}, _from, [wallet,miner]) do
    recipientAddress = User.address(recipient)
    {:reply, Wallet.send(amount, recipientAddress, wallet), [wallet, miner]}
  end
  def handle_call({:addFreeCoins, amount}, _from, [wallet,miner]) do
    Wallet.add_free_coin(wallet, amount)
    {:reply, "Added Free Coins", [wallet,miner]}
  end
end