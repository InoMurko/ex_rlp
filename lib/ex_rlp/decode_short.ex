defmodule ExRLP.DecodeItemShort do
  @moduledoc """
    Captures bins and decodes them.
  """
  @spec decode_item(binary(), ExRLP.t()) :: ExRLP.t()
  def decode_item(rlp_binary), do: do_decode_item(rlp_binary, nil)
  def decode_item(rlp_binary, result), do: do_decode_item(rlp_binary, result)

  defp do_decode_item(<<>>, result) when is_list(result) do
    Enum.reverse(result)
  end

  defp do_decode_item(<<>>, result), do: result
  ##
  ## HANDLING 0 - 127
  ##
  defp do_decode_item(<<prefix, tail::binary>>, nil) when prefix < 128 do
    do_decode_item(tail, <<prefix>>)
  end

  defp do_decode_item(<<prefix, tail::binary>>, result) when prefix < 128 do
    do_decode_item(tail, [<<prefix>> | result])
  end

  ##
  ## FINISHED HANDLING 0 - 127
  ##

  ##
  ## HANDLING 128 - 183
  ##
  defp do_decode_item(<<prefix, tail::binary>>, nil) when prefix <= 183 do
    item_length = prefix - 128
    <<item::binary-size(item_length), new_tail::binary>> = tail
    do_decode_item(new_tail, item)
  end

  defp do_decode_item(<<prefix, tail::binary>>, result) when prefix <= 183 do
    item_length = prefix - 128
    <<item::binary-size(item_length), new_tail::binary>> = tail
    do_decode_item(new_tail, [item | result])
  end

  ##
  ## FINISHED HANDLING 128-183
  ##

  # decode_long_binary - CAN'T OPTIMISE FOR NOW
  defp do_decode_item(<<be_size_prefix, tail::binary>>, nil) when be_size_prefix < 192 do
    {new_item, new_tail} = decode_long_binary(be_size_prefix - 183, tail)

    do_decode_item(new_tail, new_item)
  end

  defp do_decode_item(<<be_size_prefix, tail::binary>>, result) when be_size_prefix < 192 do
    {new_item, new_tail} = decode_long_binary(be_size_prefix - 183, tail)

    do_decode_item(new_tail, [new_item | result])
  end

  ##
  ## HANDLING 192
  ##
  defp do_decode_item(<<192, tail::binary>>, nil) do
    do_decode_item(tail, [])
  end

  defp do_decode_item(<<192, tail::binary>>, result) do
    do_decode_item(tail, [[] | result])
  end

  ##
  ## FINISHED HANDLING 192
  ##

  ##
  ## HANDLING 193-247
  ##
  defp do_decode_item(<<prefix, tail::binary>>, nil) when prefix <= 247 do
    item_length = prefix - 192
    <<item::binary-size(item_length), new_tail::binary>> = tail
    new_item = Enum.reverse(decode_item(item, []))
    do_decode_item(new_tail, new_item)
  end

  defp do_decode_item(<<prefix, tail::binary>>, result) when prefix <= 247 do
    item_length = prefix - 192
    <<item::binary-size(item_length), new_tail::binary>> = tail
    new_item = decode_item(item, [])
    do_decode_item(new_tail, [new_item | result])
  end

  ##
  ## FINISHED HANDLING 193-247
  ##

  # decode_long_binary - CAN'T OPTIMISE FOR NOW
  defp do_decode_item(<<be_size_prefix, tail::binary>>, nil) do
    {list, new_tail} = decode_long_binary(be_size_prefix - 247, tail)

    new_result = Enum.reverse(decode_item(list, []))

    do_decode_item(new_tail, new_result)
  end

  defp do_decode_item(<<be_size_prefix, tail::binary>>, result) do
    {list, new_tail} = decode_long_binary(be_size_prefix - 247, tail)

    new_result = decode_item(list, [])

    do_decode_item(new_tail, [new_result | result])
  end

  @spec decode_long_binary(integer(), binary()) :: {binary(), binary()}
  defp decode_long_binary(be_size, tail) do
    <<be::binary-size(be_size), data::binary>> = tail

    item_length = :binary.decode_unsigned(be)

    <<item::binary-size(item_length), new_tail::binary>> = data

    {item, new_tail}
  end
end
