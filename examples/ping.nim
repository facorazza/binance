#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

import binance

const apiKey = slurp("./keys/api.key")
const secretKey = slurp("./keys/secret.key")
let b = newBinanceApi(apiKey, secretKey)


if b.ping():
  echo "The server is online."
else:
  echo "The server is offline."
