defmodule Project4 do
  @moduledoc """
  Documentation for Project4.
  """

  @doc """

  """
  @errorString "Error: Invalid Input \nValid input: ./project4 numNodes"

  def main(args) do
    with parsedArgs = args |> parse_args() do
      cond do
        length(parsedArgs) == 1 ->
          [numNodes] = parsedArgs
          channel = setupPhoenix()
#          pushMessage(channel, "HELLO")
          start_demo(channel, numNodes)
        true ->
          IO.puts(@errorString)
      end
    end
  end

  @doc """
  Parse the arguments into the required form
  """
  def parse_args(args) when length(args) != 1 do
    IO.puts(@errorString)

    # stop the program from running
    System.halt(0)
  end

  def parse_args(args) do
    args
    |> args_to_internal_representation()
  end

  defp args_to_internal_representation([numNodes]) do
    [toInteger(numNodes)]
  end

  def toInteger(number) do
    if match?({_, ""}, Integer.parse(number)) do
      value = String.to_integer(number)
      value
    else
      IO.puts(@errorString)
      System.halt(0)
    end
  end

  def start_demo(channel, numNodes) do

    BlockChain.start()
    Miners.start()

    peers = Enum.reduce(0..numNodes-1, [],
      fn index, acc ->

        if index == 0 do
          {:ok, user} = User.start()
          miner = User.miner(user)
          Miners.add(miner)
          [user]
        else
          {:ok, user} = User.start()
          miner = User.miner(user)
          Miners.add(miner)
          acc ++ [user]
        end

      end)

    firstPeer = Enum.at(peers, 0)
    User.add_free_coins(firstPeer, 1000)

    firstPeerAddress = User.address(firstPeer)
    pushMessage(channel, "Added 1000 free coins to <#{firstPeerAddress}> account")
    IO.puts("Added 1000 free coins to <#{firstPeerAddress}> account")

    senders = [firstPeer]
    receivers = peers

    transferCoins(channel, senders, receivers, 10)
  end

  def transferCoins(channel, senders, receivers, counter) when counter > 0 do
    sender = Enum.random(senders)
    receiver = Enum.random(receivers--[sender])
    amount = round((User.balance(sender) * 50) / 100)

    senders_address =  "#{User.address(sender)}"
    receiver_address =  "#{User.address(receiver)}"

    if amount > 0 do
      pushMessage(channel, "Sending #{inspect amount} coins from <#{senders_address}> to <#{receiver_address}>")
      IO.puts("Sending #{inspect amount} coins from <#{senders_address}> to <#{receiver_address}>")

      User.send(sender, amount, receiver)

      Process.sleep(1000*10)
      IO.puts("==================================================================")
      IO.puts("===== #{inspect sender}'s Balance #{inspect User.balance(sender)} ")
      IO.puts("===== #{inspect receiver}'s Balance #{inspect User.balance(receiver)} ")
      IO.puts("==================================================================")

      transcation_id = Integer.to_string(10-counter+1)
      senders_balance = User.balance(sender)
      receiver_balance = User.balance(receiver)

      pushMessage(channel, transcation_id, amount, senders_address, senders_balance, receiver_address, receiver_balance)

      transferCoins(channel, Enum.uniq(senders ++ [receiver]), receivers, counter - 1)
      else
      transferCoins(channel, senders, receivers, counter)
    end

  end

  def transferCoins(channel, senders, _, _) do
    Process.sleep(1000*5)
    IO.puts("==================================================================")
    Enum.each(0..length(senders)-1,
      fn sender_index ->
        pushMessage(channel, User.address(Enum.at(senders, sender_index)), User.balance(Enum.at(senders, sender_index)))
         #Balance #{inspect User.balance(sender)} ")
        IO.puts("===== #{inspect Enum.at(senders, sender_index)}'s Balance #{inspect User.balance(Enum.at(senders, sender_index))} ")
      end)
    IO.puts("==================================================================")
  end

  def setupPhoenix() do
    {:ok, pid} = PhoenixChannelClient.start_link()
    {:ok, socket} = PhoenixChannelClient.connect(pid,
      host: "localhost",
      path: "/socket/websocket",
      params: %{token: "something"},
      port: 4000,
      secure: false)

    IO.inspect self()
    IO.inspect socket
    name = "sagar"
    channel = PhoenixChannelClient.channel(socket, "room:lobby", name)
    #ChannelClient.start_link(channel, handlers: handlers)
    joinChannel(channel)
    channel
  end

  def pushMessage(channel, message) do
    case PhoenixChannelClient.push_and_receive(channel, "new:new_msg", %{message: message}, 100) do
      {:ok, msg} -> msg
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout ->  IO.puts("")
    end
  end

  def pushMessage(channel, transaction_id, amount, senders_address, senders_balance, receiver_address, receiver_balance) do

    case PhoenixChannelClient.push_and_receive(channel, "new:transaction",
     %{transaction_id: transaction_id,
        amount: amount,
        senders_address: senders_address,
        senders_balance: senders_balance,
        receiver_address: receiver_address,
        receiver_balance: receiver_balance},
        1000) do
      {:ok, msg} -> msg
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout ->  IO.puts("")
    end
  end

  def pushMessage(channel, address, balance) do

    case PhoenixChannelClient.push_and_receive(channel, "new:ledger",
     %{address: address,
        balance: balance},
        1000) do
      {:ok, msg} -> msg
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout ->  IO.puts("")
    end
  end

  def pushMessage(channel, block_index, address, time, timestamp) do

    case PhoenixChannelClient.push_and_receive(channel, "new:mining",
     %{block_index: block_index,
       address: address,
        time: time,
        timestamp: timestamp},
        1000) do
      {:ok, msg} -> msg
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout -> IO.puts("")
    end
  end


  def joinChannel(channel) do
    case PhoenixChannelClient.join(channel) do
      {:ok, _} -> IO.puts "ok"
      {:ok, %{message: message}} -> IO.puts(message)
      {:error, %{reason: reason}} -> IO.puts(reason)
      :timeout ->  IO.puts("")
    end
  end

end
