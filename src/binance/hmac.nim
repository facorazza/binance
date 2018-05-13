import strutils
import nimSHA2

proc hmac_sha256*(key, data: string): string =
  const digest_size = 32
  const block_size = 64
  const opad = 0x5c
  const ipad = 0x36

  var keyA: seq[uint8] = @[]
  var o_key_pad = newString(block_size + digest_size)
  var i_key_pad = newString(block_size)

  if key.len > block_size:
    for n in computeSHA256(key): keyA.add(n.uint8)
  else:
    for n in key: keyA.add(n.uint8)

  while keyA.len < block_size: keyA.add(0x00'u8)

  for i in 0..block_size-1:
    o_key_pad[i] = char(keyA[i].ord xor opad)
    i_key_pad[i] = char(keyA[i].ord xor ipad)
  var i = 0
  for x in computeSHA256(i_key_pad & data):
    o_key_pad[block_size + i] = char(x)
    inc(i)
  result = toHex(computeSHA256(o_key_pad))
