#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

import strutils
import binance/hmac

var result:string = hmac_sha256("NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j", "symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&recvWindow=5000&timestamp=1499827319559")
echo result
assert(toLowerAscii(result) == "c8db56825ae71d6d79447849e617115f4a920fa2acdcab2b053c4b2838bd6b71", "Incorrect hash")
