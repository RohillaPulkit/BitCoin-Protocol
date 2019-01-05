defmodule KeyPair do
  @moduledoc """
  Module to generate public key & private key. It uses crypto libraray of elixir
  """

  @type_algorithm :ecdsa
  @ecdsa_algorithm :secp256k1


  def hash(data, algo) do
    :crypto.hash(algo, data)
  end

  def public_key_hash(pk) do
    pk
    |> hash(:sha256)
    |> hash(:ripemd160)
    |> Base.encode16()
  end

  def generate_key_pair do
    {pk, sk} = :crypto.generate_key(:ecdh, @ecdsa_algorithm)
    {Base.encode16(pk), Base.encode16(sk)}
  end

  def sign(private_key, msg) do
    signature = :crypto.sign(@type_algorithm, :sha256, msg, [Base.decode16!(private_key), @ecdsa_algorithm])
    Base.encode16(signature)
  end

  def verify_signature(public_key, msg, signature) do
    sig = Base.decode16!(signature)
    pk = Base.decode16!(public_key)
    :crypto.verify(@type_algorithm, :sha256, msg, sig, [pk, @ecdsa_algorithm])
  end

end
