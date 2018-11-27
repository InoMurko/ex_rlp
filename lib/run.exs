large_rlp = (for _ <- 1..100_000 do
                [<<1>>, [<<1>>, <<2>>]]
              end)

Benchee.run(%{
  "InoShort"    => fn -> large_rlp
           |> ExRLP.encode()
           |> ExRLPShort.decode() end,
  "Ino"    => fn -> large_rlp
           |> ExRLP.encode()
           |> ExRLP.decode() end,
  "master" => fn -> large_rlp
           |> ExRLP.encode()
           |> ExRLPMaster.decode() end,

}, time: 20, memory_time: 5)