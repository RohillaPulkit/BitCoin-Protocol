defmodule ProofOfWork do

  @target_leading_zeroes "0000"

  def compute(%Block{} = block) do
    {hash, nonce} = proof_of_work(block)
    %{block | hash: hash, nonce: nonce}
  end

  def verify(hash) do
    String.starts_with?(hash, @target_leading_zeroes)
  end

  defp proof_of_work(%Block{} = block, nonce \\ 0) do
    attempt = %{block | nonce: nonce}
    hash = Block.calculate_hash(attempt)

    case verify(hash) do
      true -> {hash, nonce}
      _ ->
        randomNumber = Enum.random(1..10)
        proof_of_work(block, nonce + randomNumber)
    end
  end

end