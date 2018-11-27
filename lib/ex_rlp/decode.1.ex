defmodule ExRLP.DecodeShort do
  @moduledoc false
  alias ExRLP.DecodeItemShort
  @spec decode(binary(), keyword()) :: ExRLP.t()
  def decode(item, options \\ []) when is_binary(item) do
    item
    |> unencode(Keyword.get(options, :encoding, :binary))
    |> DecodeItemShort.decode_item()
  end

  @spec unencode(binary(), atom()) :: binary()
  defp unencode(value, :binary), do: value
  defp unencode(value, :hex), do: decode_hex(value)

  @spec decode_hex(binary()) :: binary()
  defp decode_hex(binary) do
    Base.decode16!(binary, case: :lower)
  end
end
